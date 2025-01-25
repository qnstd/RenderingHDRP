#ifndef LW_SP_DEPTHANDSHADOW
#define LW_SP_DEPTHANDSHADOW

// 标记检测
#if (SHADERPASS != SHADERPASS_DEPTH_ONLY && SHADERPASS != SHADERPASS_SHADOWS && SHADERPASS != SHADERPASS_TRANSPARENT_DEPTH_PREPASS && SHADERPASS != SHADERPASS_TRANSPARENT_DEPTH_POSTPASS)
#error SHADERPASS_is_not_correctly_define
#endif


#define WRITE_NORMAL_BUFFER


// 引入贴花
#if defined(WRITE_DECAL_BUFFER) && !defined(_DISABLE_DECALS)
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalPrepassBuffer.hlsl"
#endif

// 引入片元着色前的相关处理
#include "LW_PrevFragment.hlsl"


#if defined(WRITE_NORMAL_BUFFER) && defined(WRITE_MSAA_DEPTH)
#define SV_TARGET_DECAL SV_Target2
#elif defined(WRITE_NORMAL_BUFFER) || defined(WRITE_MSAA_DEPTH)
#define SV_TARGET_DECAL SV_Target1
#else
#define SV_TARGET_DECAL SV_Target0
#endif


/*
    片元着色
*/
void Frag(  PackedVaryingsToPS packedInput
            #ifdef WRITE_MSAA_DEPTH
            , out float4 depthColor : SV_Target0
                #ifdef WRITE_NORMAL_BUFFER
                , out float4 outNormalBuffer : SV_Target1
                #endif
            #else
                #ifdef WRITE_NORMAL_BUFFER
                , out float4 outNormalBuffer : SV_Target0
                #endif
            #endif

            #if defined(WRITE_DECAL_BUFFER) && !defined(_DISABLE_DECALS)
            , out float4 outDecalBuffer : SV_TARGET_DECAL
            #endif

            #if defined(_DEPTHOFFSET_ON) && !defined(SCENEPICKINGPASS)
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

#if defined(_DEPTHOFFSET_ON) && !defined(SCENEPICKINGPASS)
    outputDepth = posInput.deviceDepth;
    #if SHADERPASS == SHADERPASS_SHADOWS
        float bias = max(abs(ddx(posInput.deviceDepth)), abs(ddy(posInput.deviceDepth))) * _SlopeScaleDepthBias;
        outputDepth += bias;
    #endif
#endif


// MSAA 深度
#ifdef WRITE_MSAA_DEPTH
    depthColor = packedInput.vmesh.positionCS.z;
    depthColor.a = SharpenAlpha(builtinData.opacity, builtinData.alphaClipTreshold);
#endif

// 法线缓冲
#if defined(WRITE_NORMAL_BUFFER)
    EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), outNormalBuffer);
#endif

// 贴花缓冲
#if defined(WRITE_DECAL_BUFFER) && !defined(_DISABLE_DECALS)
    DecalPrepassData decalPrepassData;
    decalPrepassData.geomNormalWS = surfaceData.geomNormalWS;
    decalPrepassData.decalLayerMask = GetMeshRenderingDecalLayer();
    EncodeIntoDecalPrepassBuffer(decalPrepassData, outDecalBuffer);
#endif
}


#endif //投影、深度着色程序 | 作者：强辰