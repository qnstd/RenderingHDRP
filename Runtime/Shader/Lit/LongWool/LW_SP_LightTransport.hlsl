#ifndef LW_SP_LIGHTTRANSPORT
#define LW_SP_LIGHTTRANSPORT

// 标记检测
#if SHADERPASS != SHADERPASS_LIGHT_TRANSPORT
#error SHADERPASS_is_not_correctly_define
#endif

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/MetaPass.hlsl"

// 引入片元着色前的相关处理
#include "LW_PrevFragment.hlsl"



/*
    片元着色
*/
float4 Frag(PackedVaryingsToPS packedInput) : SV_Target
{
    FragInputs input = UnpackVaryingsToFragInputs(packedInput);
    PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

#ifdef VARYINGS_NEED_POSITION_WS
    float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
#else
    float3 V = float3(1.0, 1.0, 1.0); 
#endif

    SurfaceData surfaceData;
    BuiltinData builtinData;
    GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);

    BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);
    LightTransportData lightTransportData = GetLightTransportData(surfaceData, builtinData, bsdfData);

    // 构建Meta输入
    UnityMetaInput metaInput;
    metaInput.Albedo = lightTransportData.diffuseColor.rgb; // 反照率 
    metaInput.Emission = lightTransportData.emissiveColor; // 自发光
#ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = input.texCoord1.xy;
    metaInput.LightCoord = float4(input.texCoord2.xy, input.texCoord3.xy);
#endif
    float4 res = float4(0.0, 0.0, 0.0, 1.0);
    res = UnityMetaFragment(metaInput);
    return res;
}


#endif //对应Shader Pass的Meta，用于烘焙 GI 着色操作 | 作者：强辰