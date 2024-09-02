#ifndef GRAPHI_LITVARYMESHVERTEX_FORWARD
#define GRAPHI_LITVARYMESHVERTEX_FORWARD


// 定义顶点、片元数据结构中需要的属性
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR

#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TANGENT_TO_WORLD
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
#define VARYINGS_NEED_COLOR
//#define VARYINGS_NEED_CULLFACE // 以在 Graphi-LitInclude 中进行动态判定，无需在此处添加。
//#define VARYINGS_NEED_POSITIONPREDISPLACEMENT_WS

#define FRAG_INPUTS_USE_TEXCOORD0
#define FRAG_INPUTS_USE_TEXCOORD1
#define FRAG_INPUTS_USE_TEXCOORD2
#define FRAG_INPUTS_USE_TEXCOORD3
//#define FRAG_INPUTS_ENABLE_STRIPPING
        

// 引入Fragment片元程序输入的数据结构
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"


// 支持混合高光
#define SUPPORT_BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
// 开启光循环
#define HAS_LIGHTLOOP 1
// 开启带光照的渲染模式
#define SHADER_LIT 1
#define RAYTRACING_SHADER_GRAPH_DEFAULT

        
// 引入光照计算需要的文件
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"



struct AttributesMesh
{// 顶点原始数据
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        float4 uv3 : TEXCOORD3;
        float4 color :COLOR;
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
    #endif
};
struct VaryingsMeshToPS
{// 变体数据
    SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
        float3 positionRWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float4 texCoord1;
        float4 texCoord2;
        float4 texCoord3;
        float4 color;
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
    #endif
};
            
struct PackedVaryingsMeshToPS
{// 将变体数据进行打包，以便在片元中使用
    SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
        float4 tangentWS : INTERP0;
        float4 texCoord0 : INTERP1;
        float4 texCoord1 : INTERP2;
        float4 texCoord2 : INTERP3;
        float4 texCoord3 : INTERP4;
        float3 positionRWS : INTERP5;
        float3 normalWS : INTERP6;
        float4 color : INTERP7;
    #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
    #endif
};
       
// 打包顶点的变体数据结构
PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
{
    PackedVaryingsMeshToPS output;
    ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);

    output.positionCS = input.positionCS;
    output.tangentWS.xyzw = input.tangentWS;
    output.texCoord0.xyzw = input.texCoord0;
    output.texCoord1.xyzw = input.texCoord1;
    output.texCoord2.xyzw = input.texCoord2;
    output.texCoord3.xyzw = input.texCoord3;
    output.positionRWS.xyz = input.positionRWS;
    output.normalWS.xyz = input.normalWS;
    output.color.xyzw = input.color;

    #if UNITY_ANY_INSTANCING_ENABLED
    output.instanceID = input.instanceID;
    #endif

    return output;
}
// 解包顶点变体数据结构
VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
{
    VaryingsMeshToPS output;

    output.positionCS = input.positionCS;
    output.tangentWS = input.tangentWS.xyzw;
    output.texCoord0 = input.texCoord0.xyzw;
    output.texCoord1 = input.texCoord1.xyzw;
    output.texCoord2 = input.texCoord2.xyzw;
    output.texCoord3 = input.texCoord3.xyzw;
    output.positionRWS = input.positionRWS.xyz;
    output.normalWS = input.normalWS.xyz;
    output.color = input.color.xyzw;

    #if UNITY_ANY_INSTANCING_ENABLED
    output.instanceID = input.instanceID;
    #endif

    return output;
}


#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES AttributesMesh
#define VaryingsMeshType VaryingsMeshToPS
#define VFX_SRP_VARYINGS VaryingsMeshType
#define VFX_SRP_SURFACE_INPUTS FragInputs
#endif


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
{// 将顶点原始数据传递给顶点描述信息结构
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);
    output.ObjectSpaceNormal    =   input.normalOS;
    output.ObjectSpaceTangent   =   input.tangentOS.xyz;
    output.ObjectSpacePosition  =   input.positionOS;
    return output;
}
        
VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{// 将顶点描述信息结构的数据传递给用于计算的顶点数据
    VertexDescription description = (VertexDescription)0;
    description.Position    = IN.ObjectSpacePosition;
    description.Normal      = IN.ObjectSpaceNormal;
    description.Tangent     = IN.ObjectSpaceTangent;
    return description;
}

// 获取用于计算的顶点数据结构
VertexDescription GetVertexDescription(AttributesMesh input, float3 timeParameters
#ifdef HAVE_VFX_MODIFICATION
    , AttributesElement element
#endif
)
{
    VertexDescriptionInputs vertexDescriptionInputs = AttributesMeshToVertexDescriptionInputs(input);
        
    #ifdef HAVE_VFX_MODIFICATION
    // 如果定义了VFX视觉特效
        GraphProperties properties;
        ZERO_INITIALIZE(GraphProperties, properties);
        // 获取粒子系统的顶点数据
        GetElementVertexProperties(element, properties);
        VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs, properties);
    #else
    // 常规
        VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
    #endif
        return vertexDescription;
}




#endif //光照前向渲染，网格顶点变体逻辑操作（由 Graphi 着色库工具生成）| 作者：强辰