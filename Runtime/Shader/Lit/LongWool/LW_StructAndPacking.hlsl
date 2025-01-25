#ifndef LW_STRUCTANDPACKING
#define LW_STRUCTANDPACKING

// 顶点源数据信息
struct AttributesMesh
{
#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
float4 uv2 : TEXCOORD2;
float4 uv3 : TEXCOORD3;

#elif SHADERPASS == SHADERPASS_SHADOWS
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;

#else
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;

#endif
        
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
    #endif
};


// 用于承接顶点着色阶段的数据，完整拷贝顶点源信息，为后续操作做准备。
struct TesselationMesh
{
#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
float4 uv2 : TEXCOORD2;
float4 uv3 : TEXCOORD3;

#elif SHADERPASS == SHADERPASS_SHADOWS
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;

#else
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;

#endif
        
#if UNITY_ANY_INSTANCING_ENABLED
    uint instanceID : INSTANCEID_SEMANTIC;
#endif
};


// 几何着色阶段使用的临时数据结构
struct GeoMesh
{
    #if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
float4 uv2 : TEXCOORD2;
float4 uv3 : TEXCOORD3;
float2 finUV : TEXCOORD4;
float3 finTangentWS : TEXCOORD5;

#elif SHADERPASS == SHADERPASS_SHADOWS
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float2 finUV : TEXCOORD0;
float3 finTangentWS : TEXCOORD1;

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float2 finUV : TEXCOORD1;
float3 finTangentWS : TEXCOORD2;

#else
float3 positionOS : INTERTESSPOS;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
float2 finUV : TEXCOORD2;
float3 finTangentWS : TEXCOORD3;

#endif
        
#if UNITY_ANY_INSTANCING_ENABLED
    uint instanceID : INSTANCEID_SEMANTIC;
#endif
};


// 对即将传入片元着色阶段的输入数据进行插值
struct VaryingsMeshToPS
{
    SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
float3 positionRWS;
float3 positionPredisplacementRWS;
float4 texCoord0;
float4 texCoord1;
float4 texCoord2;
float4 texCoord3;
float2 finUV;
float3 finTangentWS;

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
float3 positionRWS;
float3 normalWS;
float4 tangentWS;
float4 texCoord0;
float2 finUV;
float3 finTangentWS;

#elif SHADERPASS == SHADERPASS_SHADOWS
float2 finUV;
float3 finTangentWS;

#else
float3 positionRWS;
float3 normalWS;
float4 tangentWS;
float4 texCoord0;
float4 texCoord1;
float2 finUV;
float3 finTangentWS;

#endif

    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
    #endif
};

// 对插值的数据结构打包
struct PackedVaryingsMeshToPS
{
    SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
float4 texCoord0 : INTERP0;
float4 texCoord1 : INTERP1;
float4 texCoord2 : INTERP2;
float4 texCoord3 : INTERP3;
float3 positionRWS : INTERP4;
float3 positionPredisplacementRWS : INTERP5;
float2 finUV : INTERP6;
float3 finTangentWS : INTERP7;

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
float4 tangentWS : INTERP0;
float4 texCoord0 : INTERP1;
float3 positionRWS : INTERP2;
float3 normalWS : INTERP3;
float2 finUV : INTERP4;
float3 finTangentWS : INTERP5;

#elif SHADERPASS == SHADERPASS_SHADOWS
float2 finUV : INTERP0;
float3 finTangentWS : INTERP1;

#else
float4 tangentWS : INTERP0;
float4 texCoord0 : INTERP1;
float4 texCoord1 : INTERP2;
float3 positionRWS : INTERP3;
float3 normalWS : INTERP4;
float2 finUV : INTERP5;
float3 finTangentWS : INTERP6;

#endif
        
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
    #endif
};


// 表面信息结构（用于后续的光照等相关的计算）
struct SurfaceDescription
{
#if SHADERPASS != SHADERPASS_SHADOWS
    float3 BaseColor;
    float3 Emission;
    float3 BentNormal;
    float Smoothness;
    float Occlusion;
    float3 NormalTS;
    float CoatMask;
    float Metallic;
#endif
    float Alpha;
    float AlphaClipThreshold;
    float AlphaClipThresholdShadow;
};

// 完整拷贝顶点源数据信息
TesselationMesh CopyAttributesMesh(AttributesMesh input)
{
    TesselationMesh o = (TesselationMesh)0;

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
o.positionOS = input.positionOS;
o.normalOS = input.normalOS;
o.uv0 = input.uv0;
o.uv1 = input.uv1;
o.uv2 = input.uv2;
o.uv3 = input.uv3;

#elif SHADERPASS == SHADERPASS_SHADOWS
o.positionOS = input.positionOS;
o.normalOS = input.normalOS;
o.tangentOS = input.tangentOS;

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
o.positionOS = input.positionOS;
o.normalOS = input.normalOS;
o.tangentOS = input.tangentOS;
o.uv0 = input.uv0;

#else
o.positionOS = input.positionOS;
o.normalOS = input.normalOS;
o.tangentOS = input.tangentOS;
o.uv0 = input.uv0;
o.uv1 = input.uv1;

#endif
        
#if UNITY_ANY_INSTANCING_ENABLED
    o.instanceID = input.instanceID;
#endif
    
    return o;
}

// 打包插值数据结构
PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
{
    PackedVaryingsMeshToPS output;
    ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);

    output.positionCS = input.positionCS;
    output.finUV = input.finUV;
    output.finTangentWS = input.finTangentWS;

    #if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
        output.texCoord0.xyzw = input.texCoord0;
        output.texCoord1.xyzw = input.texCoord1;
        output.texCoord2.xyzw = input.texCoord2;
        output.texCoord3.xyzw = input.texCoord3;
        output.positionRWS.xyz = input.positionRWS;
        output.positionPredisplacementRWS.xyz = input.positionPredisplacementRWS;
        

    #elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
        output.tangentWS.xyzw = input.tangentWS;
        output.texCoord0.xyzw = input.texCoord0;
        output.positionRWS.xyz = input.positionRWS;
        output.normalWS.xyz = input.normalWS;

    #elif SHADERPASS == SHADERPASS_SHADOWS
    #else
        output.tangentWS.xyzw = input.tangentWS;
        output.texCoord0.xyzw = input.texCoord0;
        output.texCoord1.xyzw = input.texCoord1;
        output.positionRWS.xyz = input.positionRWS;
        output.normalWS.xyz = input.normalWS;
    #endif

    #if UNITY_ANY_INSTANCING_ENABLED
    output.instanceID = input.instanceID;
    #endif
    return output;
}

// 解包插值数据结构
VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
{
    VaryingsMeshToPS output;
    output.positionCS = input.positionCS;
    output.finUV = input.finUV;
    output.finTangentWS = input.finTangentWS;

    #if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
        output.texCoord0 = input.texCoord0.xyzw;
        output.texCoord1 = input.texCoord1.xyzw;
        output.texCoord2 = input.texCoord2.xyzw;
        output.texCoord3 = input.texCoord3.xyzw;
        output.positionRWS = input.positionRWS.xyz;
        output.positionPredisplacementRWS = input.positionPredisplacementRWS.xyz;
        

    #elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
        output.tangentWS = input.tangentWS.xyzw;
        output.texCoord0 = input.texCoord0.xyzw;
        output.positionRWS = input.positionRWS.xyz;
        output.normalWS = input.normalWS.xyz;

    #elif SHADERPASS == SHADERPASS_SHADOWS

    #else
        output.tangentWS = input.tangentWS.xyzw;
        output.texCoord0 = input.texCoord0.xyzw;
        output.texCoord1 = input.texCoord1.xyzw;
        output.positionRWS = input.positionRWS.xyz;
        output.normalWS = input.normalWS.xyz;

    #endif

    #if UNITY_ANY_INSTANCING_ENABLED
    output.instanceID = input.instanceID;
    #endif
    return output;
}


// 解析并获取片元着色阶段的输入数据
FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);

    FragInputs output;
    ZERO_INITIALIZE(FragInputs, output);
        
    output.tangentToWorld = k_identity3x3;
    output.positionSS = unpacked.positionCS; // unpacked.positionCS 就是 SV_Position
    output.finUV        =   unpacked.finUV;
    output.finTangentWS =   unpacked.finTangentWS;

    #if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
        output.positionRWS =                unpacked.positionRWS;
        output.positionPredisplacementRWS = unpacked.positionPredisplacementRWS;
        output.texCoord0 =                  unpacked.texCoord0;
        output.texCoord1 =                  unpacked.texCoord1;
        output.texCoord2 =                  unpacked.texCoord2;
        output.texCoord3 =                  unpacked.texCoord3;
        

    #elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
        output.positionRWS =                unpacked.positionRWS;
        output.tangentToWorld =             BuildTangentToWorld(unpacked.tangentWS, unpacked.normalWS);
        output.texCoord0 =                  unpacked.texCoord0;

    #elif SHADERPASS == SHADERPASS_SHADOWS

    #else
        output.positionRWS =                unpacked.positionRWS;
        output.tangentToWorld =             BuildTangentToWorld(unpacked.tangentWS, unpacked.normalWS);
        output.texCoord0 =                  unpacked.texCoord0;
        output.texCoord1 =                  unpacked.texCoord1;

    #endif

    return output;
}


#endif //数据结构及解压、转换 | 作者：强辰