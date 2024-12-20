#ifndef FURSHADERPASSMOTIONVECTOR
#define FURSHADERPASSMOTIONVECTOR

#if SHADERPASS != SHADERPASS_MOTION_VECTORS
    #error SHADERPASS_is_not_correctly_define
#endif


#include "FurMotionVectorVertMesh.hlsl"
#if defined(WRITE_DECAL_BUFFER) && !defined(_DISABLE_DECALS)
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalPrepassBuffer.hlsl"
#endif


/*
    顶点着色
*/
PackedVaryingsType Vert(AttributesMesh inputMesh, AttributesPass inputPass)
{
    VaryingsType varyingsType;
    varyingsType.vmesh = VertMesh(inputMesh);
    return MotionVectorVS(varyingsType, inputMesh, inputPass);
}


/*
    几何着色器不做任何处理，直接送入片元着色模块
    这里只管默认的顶点处理，不对扩展出来的新顶点处理。
*/
[maxvertexcount(3)] 
void Geom(triangle PackedVaryingsType input[3], inout TriangleStream<PackedVaryingsType> stream)
{
    for(int j=0; j<3; j++)
    {
        stream.Append( input[j] );
    }
    stream.RestartStrip();
}



// 定义输出的渲染目标
#if defined(WRITE_DECAL_BUFFER) && defined(WRITE_MSAA_DEPTH)
    #define SV_TARGET_NORMAL SV_Target3
#elif defined(WRITE_DECAL_BUFFER) || defined(WRITE_MSAA_DEPTH)
    #define SV_TARGET_NORMAL SV_Target2
#else
    #define SV_TARGET_NORMAL SV_Target1
#endif



/*
    片元着色
*/
void Frag
(  
    PackedVaryingsToPS packedInput
    #ifdef WRITE_MSAA_DEPTH
    , out float4 depthColor : SV_Target0
    , out float4 outMotionVector : SV_Target1
        #ifdef WRITE_DECAL_BUFFER
        , out float4 outDecalBuffer : SV_Target2
        #endif
    #else
    , out float4 outMotionVector : SV_Target0
        #ifdef WRITE_DECAL_BUFFER
        , out float4 outDecalBuffer : SV_Target1
        #endif
    #endif

    // 法线缓冲
    #ifdef WRITE_NORMAL_BUFFER
    , out float4 outNormalBuffer : SV_TARGET_NORMAL
    #endif

    // 深度偏移
    #ifdef _DEPTHOFFSET_ON
    , out float outputDepth : DEPTH_OFFSET_SEMANTIC
    #endif
)
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

    VaryingsPassToPS inputPass = UnpackVaryingsPassToPS(packedInput.vpass);
#ifdef _DEPTHOFFSET_ON
    inputPass.positionCS.w += builtinData.depthOffset;
    inputPass.previousPositionCS.w += builtinData.depthOffset;
#endif

    float2 motionVector = CalculateMotionVector(inputPass.positionCS, inputPass.previousPositionCS);
    bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;

    if (forceNoMotion)
        outMotionVector = float4(2.0, 0.0, 0.0, 0.0);

#ifdef WRITE_MSAA_DEPTH
    depthColor = packedInput.vmesh.positionCS.z;
    depthColor.a = SharpenAlpha(builtinData.opacity, builtinData.alphaClipTreshold);
#endif

#ifdef WRITE_NORMAL_BUFFER
    EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), outNormalBuffer);
#endif

#if defined(WRITE_DECAL_BUFFER)
    DecalPrepassData decalPrepassData;
    #ifdef _DISABLE_DECALS
        ZERO_INITIALIZE(DecalPrepassData, decalPrepassData);
    #else
    
    decalPrepassData.geomNormalWS = surfaceData.geomNormalWS;
    decalPrepassData.decalLayerMask = GetMeshRenderingDecalLayer();
#endif
    EncodeIntoDecalPrepassBuffer(decalPrepassData, outDecalBuffer);
    outDecalBuffer.w = (GetMeshRenderingLightLayer() & 0x000000FF) / 255.0;
#endif

#ifdef _DEPTHOFFSET_ON
    outputDepth = posInput.deviceDepth;
#endif
}


#endif //绒毛运动模糊着色通道（由 Graphi 着色库工具生成）| 作者：强辰