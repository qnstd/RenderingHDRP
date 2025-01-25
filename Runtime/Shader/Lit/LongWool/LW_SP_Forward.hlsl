#ifndef LW_SP_FORWARD
#define LW_SP_FORWARD

// 检测Pass是否是Forward标记
#if SHADERPASS != SHADERPASS_FORWARD
#error SHADERPASS_is_not_correctly_define
#endif

// 引入片元着色前的相关处理
#include "LW_PrevFragment.hlsl"


/*
    片元着色
*/
void Frag(PackedVaryingsToPS packedInput, out float4 outColor : SV_Target0 
    #ifdef _DEPTHOFFSET_ON
        , out float outputDepth : DEPTH_OFFSET_SEMANTIC
    #endif
)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);

    FragInputs input = UnpackVaryingsToFragInputs(packedInput);
    AdjustFragInputsToOffScreenRendering(input, _OffScreenRendering > 0, _OffScreenDownsampleFactor);
    uint2 tileIndex = uint2(input.positionSS.xy) / GetTileSize();

    // positionSS 是 SV_Position语义代表的3d位置
    PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, tileIndex);

#ifdef VARYINGS_NEED_POSITION_WS
    float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
#else
    float3 V = float3(1.0, 1.0, 1.0); // 避免除0
#endif

    // 计算表面数据
    SurfaceData surfaceData;
    BuiltinData builtinData;
    GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);
    // 计算brdf数据
    BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);
    // 所有光源数据
    PreLightData preLightData = GetPreLightData(V, posInput, bsdfData);

    outColor = float4(0.0, 0.0, 0.0, 0.0);
    uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_OPAQUE;

    // 执行所有光源计算
    LightLoopOutput lightLoopOutput;
    LightLoop(V, posInput, preLightData, bsdfData, builtinData, featureFlags, lightLoopOutput);

    // 对反照率及高光进行曝光计算
    float3 diffuseLighting = lightLoopOutput.diffuseLighting;
    float3 specularLighting = lightLoopOutput.specularLighting;
    diffuseLighting *= GetCurrentExposureMultiplier();
    specularLighting *= GetCurrentExposureMultiplier();

    outColor = ApplyBlendMode(diffuseLighting, specularLighting, builtinData.opacity); // 执行混合模式
    outColor = EvaluateAtmosphericScattering(posInput, V, outColor); // 大气散射

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif
}


#endif //前向渲染通道(Forward) | 作者：强辰