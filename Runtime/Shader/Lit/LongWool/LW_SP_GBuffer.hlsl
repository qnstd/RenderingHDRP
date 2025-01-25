#ifndef LW_SP_GBUFFER
#define LW_SP_GBUFFER

// 着色程序标记验证
#if SHADERPASS != SHADERPASS_GBUFFER
#error SHADERPASS_is_not_correctly_define
#endif

// 引入片元着色前的相关处理
#include "LW_PrevFragment.hlsl"


/*
    片元着色
*/
void Frag(  PackedVaryingsToPS packedInput,
            OUTPUT_GBUFFER(outGBuffer)
            #ifdef _DEPTHOFFSET_ON
            , out float outputDepth : DEPTH_OFFSET_SEMANTIC
            #endif
            )
{
    
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);

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

    ENCODE_INTO_GBUFFER(surfaceData, builtinData, posInput.positionSS, outGBuffer);

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif
}


#endif //GBuffer着色程序 | 作者：强辰