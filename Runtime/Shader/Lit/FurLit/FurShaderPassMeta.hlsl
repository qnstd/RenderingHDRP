#ifndef FURSHADERPASSMETA
#define FURSHADERPASSMETA

#if SHADERPASS != SHADERPASS_LIGHT_TRANSPORT
#error SHADERPASS_is_not_correctly_define
#endif


#include "FurGeometry.hlsl"


// 片元着色
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

    float4 res = float4(0.0, 0.0, 0.0, 1.0);

    UnityMetaInput metaInput;
    metaInput.Albedo = lightTransportData.diffuseColor.rgb;
    metaInput.Emission = lightTransportData.emissiveColor;
#ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = input.texCoord1.xy;
    metaInput.LightCoord = float4(input.texCoord2.xy, input.texCoord3.xy);
#endif
    res = UnityMetaFragment(metaInput);

    return res;
}


#endif //绒毛全局GI（由 Graphi 着色库工具生成）| 作者：强辰