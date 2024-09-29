#ifndef FURSTRUCTANDPACK
#define FURSTRUCTANDPACK


// 顶点着色输入结构
struct AttributesMesh
{
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        float4 uv3 : TEXCOORD3;
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
    #endif
};



// ////////////////////////////////////////////////////////
// 用于将顶点输入数据结构原封不动的拷贝并输出到后续着色阶段使用

struct CopyedAttributesMesh
{
    float4 positionOS   : INTERNALTESSPOS; // xyz：顶点坐标。w：未使用
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float4 uv0          : TEXCOORD0;
    float4 uv1          : TEXCOORD1;
    float4 uv2          : TEXCOORD2;
    float4 uv3          : TEXCOORD3;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

CopyedAttributesMesh CopyAttributesMesh(AttributesMesh input)
{
    CopyedAttributesMesh output = (CopyedAttributesMesh)0;
    output.positionOS = float4(input.positionOS, 0.0);
    output.normalOS = input.normalOS;
    output.tangentOS = input.tangentOS;
    output.uv0 = input.uv0;
    output.uv1 = input.uv1;
    output.uv2 = input.uv2;
    output.uv3 = input.uv3;
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    return output;
}

AttributesMesh RestoreAttributesMesh(CopyedAttributesMesh input)
{
    AttributesMesh output = (AttributesMesh)0;
    output.positionOS = input.positionOS.xyz;
    output.normalOS = input.normalOS;
    output.tangentOS = input.tangentOS;
    output.uv0 = input.uv0;
    output.uv1 = input.uv1;
    output.uv2 = input.uv2;
    output.uv3 = input.uv3;
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    return output;
}

// 结束
// ////////////////////////////////////////////////////////



// 送入片元着色前的数据结构
struct VaryingsMeshToPS
{
    SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
        float3 positionRWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float4 texCoord1;
        float4 texCoord2;
        float4 texCoord3;
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
    #endif
        float3 positionPredisplacementRWS;
};

// 送入片元着色前的数据结构，打包插值后的结构
struct PackedVaryingsMeshToPS
{
    SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
        float4 tangentWS : INTERP0;
        float4 texCoord0 : INTERP1;
        float4 texCoord1 : INTERP2;
        float4 texCoord2 : INTERP3;
        float3 positionRWS : INTERP4;
        float3 normalWS : INTERP5;
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
    #endif
        float4 texCoord3 : INTERP6;
        float3 positionPredisplacementRWS : INTERP7;
};

// 打包插值 送入片元着色前的数据结构
PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
{
    PackedVaryingsMeshToPS output;
    ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);

    output.positionCS = input.positionCS;
    output.tangentWS.xyzw = input.tangentWS;
    output.texCoord0.xyzw = input.texCoord0;
    output.texCoord1.xyzw = input.texCoord1;
    output.texCoord2.xyzw = input.texCoord2;
    output.positionRWS.xyz = input.positionRWS;
    output.normalWS.xyz = input.normalWS;
    #if UNITY_ANY_INSTANCING_ENABLED
    output.instanceID = input.instanceID;
    #endif
    output.texCoord3.xyzw = input.texCoord3;
    output.positionPredisplacementRWS.xyz = input.positionPredisplacementRWS;

    return output;
}
        
// 解包
VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
{
    VaryingsMeshToPS output;

    output.positionCS = input.positionCS;
    output.tangentWS = input.tangentWS.xyzw;
    output.texCoord0 = input.texCoord0.xyzw;
    output.texCoord1 = input.texCoord1.xyzw;
    output.texCoord2 = input.texCoord2.xyzw;
    output.positionRWS = input.positionRWS.xyz;
    output.normalWS = input.normalWS.xyz;
    #if UNITY_ANY_INSTANCING_ENABLED
    output.instanceID = input.instanceID;
    #endif
    output.texCoord3 = input.texCoord3.xyzw;
    output.positionPredisplacementRWS = input.positionPredisplacementRWS.xyz;

    return output;
}



struct VertexDescriptionInputs
{
    float3 ObjectSpaceNormal;
    float3 ObjectSpaceTangent;
    float3 ObjectSpacePosition;
};

struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};


VertexDescriptionInputs AttributesMeshToVertexDescriptionInputs(AttributesMesh input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
        
    return output;
}

 
VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}
      

VertexDescription GetVertexDescription(AttributesMesh input, float3 timeParameters)
{
    VertexDescriptionInputs vertexDescriptionInputs = AttributesMeshToVertexDescriptionInputs(input);
    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
    return vertexDescription;
}


// 顶点着色器中修改顶点信息的函数
// 此处只是为了实现底层甩出的接口，没有其他任何意义。具体的顶点变换及操作交由几何着色器执行。
AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters
#ifdef USE_CUSTOMINTERP_SUBSTRUCT
    , inout VaryingsMeshToPS varyings
#endif
    )
{
    VertexDescription vertexDescription = GetVertexDescription(input, timeParameters);
    input.positionOS = vertexDescription.Position;
    input.normalOS = vertexDescription.Normal;
    input.tangentOS.xyz = vertexDescription.Tangent;
    return input;
}



FragInputs BuildFragInputs(VaryingsMeshToPS input)
{
    FragInputs output;
    ZERO_INITIALIZE(FragInputs, output);
        
    output.tangentToWorld = k_identity3x3;
    output.positionSS = input.positionCS;
        
    output.positionRWS =                input.positionRWS;
    output.positionPredisplacementRWS = input.positionPredisplacementRWS;
    output.tangentToWorld =             BuildTangentToWorld(input.tangentWS, input.normalWS);
    output.texCoord0 =                  input.texCoord0;
    output.texCoord1 =                  input.texCoord1;
    output.texCoord2 =                  input.texCoord2;
    output.texCoord3 =                  input.texCoord3;

        
    // splice point to copy custom interpolator fields from varyings to frag inputs
        
    return output;
}
        
FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
{
    UNITY_SETUP_INSTANCE_ID(input);
#if defined(HAVE_VFX_MODIFICATION) && defined(UNITY_INSTANCING_ENABLED)
    unity_InstanceID = input.instanceID;
#endif
    VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
    return BuildFragInputs(unpacked);
}



struct SurfaceDescriptionInputs
{
    float3 TangentSpaceNormal;
    float4 uv0;
    float4 uv3;
};
     
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float3 BentNormal;
    float Smoothness;
    float Occlusion;
    float3 NormalTS;
    float CoatMask;
    float Metallic;
    float4 VTPackedFeedback;
    float Alpha; // 透明度
    float AlphaClipThreshold; // 透明裁剪阔值
    float AlphaClip; // 用于透明裁剪剔除的属性
};


SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
    output.uv0 =                                        input.texCoord0;
    output.uv3 =                                        input.texCoord3;

    // splice point to copy frag inputs custom interpolator pack into the SDI

    return output;
}


#endif //绒毛顶点数据结构、操作等（由 Graphi 着色库工具生成）| 作者：强辰