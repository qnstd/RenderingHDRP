#ifndef FURSHADERPASSFORWARD
#define FURSHADERPASSFORWARD

#if SHADERPASS != SHADERPASS_FORWARD
#error SHADERPASS_is_not_correctly_define
#endif


#include "FurGeometry.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplayMaterial.hlsl"


#ifdef UNITY_VIRTUAL_TEXTURING
    #ifdef OUTPUT_SPLIT_LIGHTING
        #define DIFFUSE_LIGHTING_TARGET SV_Target2
        #define SSS_BUFFER_TARGET SV_Target3
    #elif defined(_WRITE_TRANSPARENT_MOTION_VECTOR)
        #define MOTION_VECTOR_TARGET SV_Target2
    #endif
    #if defined(SHADER_API_PSSL)
        #pragma PSSL_target_output_format(target 1 FMT_32_ABGR)
    #endif
#else
    #ifdef OUTPUT_SPLIT_LIGHTING
        #define DIFFUSE_LIGHTING_TARGET SV_Target1
        #define SSS_BUFFER_TARGET SV_Target2
    #elif defined(_WRITE_TRANSPARENT_MOTION_VECTOR)
        #define MOTION_VECTOR_TARGET SV_Target1
    #endif
#endif


/*
    片元着色
*/
void Frag
(
    PackedVaryingsToPS packedInput
    , out float4 outColor : SV_Target0 
    #ifdef UNITY_VIRTUAL_TEXTURING
        , out float4 outVTFeedback : SV_Target1
    #endif
    #ifdef OUTPUT_SPLIT_LIGHTING
        , out float4 outDiffuseLighting : DIFFUSE_LIGHTING_TARGET
        , OUTPUT_SSSBUFFER(outSSSBuffer) : SSS_BUFFER_TARGET
    #elif defined(_WRITE_TRANSPARENT_MOTION_VECTOR)
          , out float4 outMotionVec : MOTION_VECTOR_TARGET
    #endif
    #ifdef _DEPTHOFFSET_ON
        , out float outputDepth : DEPTH_OFFSET_SEMANTIC
    #endif
)
{
#ifdef _WRITE_TRANSPARENT_MOTION_VECTOR
    outMotionVec = float4(2.0, 0.0, 0.0, 1.0);
#endif

    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
    FragInputs input = UnpackVaryingsToFragInputs(packedInput);
    // 屏幕外渲染
    AdjustFragInputsToOffScreenRendering(input, _OffScreenRendering > 0, _OffScreenDownsampleFactor);

    uint2 tileIndex = uint2(input.positionSS.xy) / GetTileSize();
    // 获取所有空间的位置信息
    PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, tileIndex);

#ifdef VARYINGS_NEED_POSITION_WS
    float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
#else
    float3 V = float3(1.0, 1.0, 1.0);
#endif
    
    // 表面及bultin数据构建
    SurfaceData surfaceData;
    BuiltinData builtinData;
    GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);

    // BSDF 数据
    BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);
    // 光源信息
    PreLightData preLightData = GetPreLightData(V, posInput, bsdfData);

    outColor = float4(0.0, 0.0, 0.0, 0.0);

#ifdef DEBUG_DISPLAY
    #ifdef OUTPUT_SPLIT_LIGHTING
        outDiffuseLighting = float4(0, 0, 0, 1);
        ENCODE_INTO_SSSBUFFER(surfaceData, posInput.positionSS, outSSSBuffer);
    #endif

    bool viewMaterial = GetMaterialDebugColor(outColor, input, builtinData, posInput, surfaceData, bsdfData);
    if (!viewMaterial)
    {
        if (_DebugFullScreenMode == FULLSCREENDEBUGMODE_VALIDATE_DIFFUSE_COLOR || _DebugFullScreenMode == FULLSCREENDEBUGMODE_VALIDATE_SPECULAR_COLOR)
        {
            float3 result = float3(0.0, 0.0, 0.0);
            GetPBRValidatorDebug(surfaceData, result);
            outColor = float4(result, 1.0f);
        }
        else if (_DebugFullScreenMode == FULLSCREENDEBUGMODE_TRANSPARENCY_OVERDRAW)
        {
            float4 result = _DebugTransparencyOverdrawWeight * float4(TRANSPARENCY_OVERDRAW_COST, TRANSPARENCY_OVERDRAW_COST, TRANSPARENCY_OVERDRAW_COST, TRANSPARENCY_OVERDRAW_A);
            outColor = result;
        }
        else
#endif
        {
            #ifdef _SURFACE_TYPE_TRANSPARENT
                uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_TRANSPARENT;
            #else
                uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_OPAQUE;
            #endif

            // 对所有光源进行光照处理
            LightLoopOutput lightLoopOutput;
            LightLoop(V, posInput, preLightData, bsdfData, builtinData, featureFlags, lightLoopOutput);

            // diffuse 及 高光颜色
            float3 diffuseLighting = lightLoopOutput.diffuseLighting;
            float3 specularLighting = lightLoopOutput.specularLighting;
            diffuseLighting *= GetCurrentExposureMultiplier();
            specularLighting *= GetCurrentExposureMultiplier();

            #ifdef OUTPUT_SPLIT_LIGHTING
                if (_EnableSubsurfaceScattering != 0 && ShouldOutputSplitLighting(bsdfData))
                {
                    outColor = float4(specularLighting, 1.0);
                    outDiffuseLighting = float4(TagLightingForSSS(diffuseLighting), 1.0);
                }
                else
                {
                    outColor = float4(diffuseLighting + specularLighting, 1.0);
                    outDiffuseLighting = float4(0, 0, 0, 1);
                }
                ENCODE_INTO_SSSBUFFER(surfaceData, posInput.positionSS, outSSSBuffer);
            #else
                // 应用混合和大气散射
                outColor = ApplyBlendMode(diffuseLighting, specularLighting, builtinData.opacity);
                outColor = EvaluateAtmosphericScattering(posInput, V, outColor);
            #endif

            // 暂时不支持半透明的运动模糊
//#ifdef _WRITE_TRANSPARENT_MOTION_VECTOR
//            VaryingsPassToPS inputPass = UnpackVaryingsPassToPS(packedInput.vpass);
//            bool forceNoMotion = any(unity_MotionVectorsParams.yw == 0.0);
//#if defined(HAVE_VFX_MODIFICATION) && !VFX_FEATURE_MOTION_VECTORS
//            forceNoMotion = true;
//#endif
//            if (!forceNoMotion)
//            {
//                float2 motionVec = CalculateMotionVector(inputPass.positionCS, inputPass.previousPositionCS);
//                EncodeMotionVector(motionVec * 0.5, outMotionVec);
//                outMotionVec.zw = 1.0;
//            }
//#endif
        }
#ifdef DEBUG_DISPLAY
    }
#endif

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif

#ifdef UNITY_VIRTUAL_TEXTURING
    float vtAlphaValue = builtinData.opacity;
    #if defined(HAS_REFRACTION) && HAS_REFRACTION
        vtAlphaValue = 1.0f - bsdfData.transmittanceMask;
    #endif
    outVTFeedback = PackVTFeedbackWithAlpha(builtinData.vtPackedFeedback, input.positionSS.xy, vtAlphaValue);
#endif
}


#endif //自定义 HLSL 文件（由 Graphi 着色库工具生成）| 作者：Graphi