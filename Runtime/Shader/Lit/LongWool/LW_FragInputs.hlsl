#ifndef LW_FRAGINPUTS
#define LW_FRAGINPUTS


#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/MaterialDebug.cs.hlsl"


#ifndef FRAG_INPUTS_ENABLE_STRIPPING
    #define FRAG_INPUTS_USE_TEXCOORD0
    #define FRAG_INPUTS_USE_TEXCOORD1
    #define FRAG_INPUTS_USE_TEXCOORD2
    #define FRAG_INPUTS_USE_TEXCOORD3
#endif


/*
    片元着色器输入结构
*/
struct FragInputs
{
    // 包含由 SV POSITION 返回的值（即 packkedvarying 中的名称 positionCS）。
    // xy: 非归一化的屏幕位置（偏移0.5），z：设备深度，w：视图空间深度
    // [注意] 
    //      SV POSITION 是剪辑空间位置，提供给顶点着色器的结果，通过视口进行转换
    //      如果使用了深度偏移（DepthOffset），则 w 值就是深度偏移
    float4 positionSS; 
    // 当前世界位置（相对于摄像机空间的世界位置）
    float3 positionRWS;
    // 上一次的世界位置（相对于摄像机空间的世界位置）
    float3 positionPredisplacementRWS; // Relative camera space position
    // 像素位置 (VPOS)
    float2 positionPixel;

    // uv
    #ifdef FRAG_INPUTS_USE_TEXCOORD0
        float4 texCoord0;
    #endif

    #ifdef FRAG_INPUTS_USE_TEXCOORD1
        float4 texCoord1;
    #endif

    #ifdef FRAG_INPUTS_USE_TEXCOORD2
        float4 texCoord2;
    #endif

    #ifdef FRAG_INPUTS_USE_TEXCOORD3
        float4 texCoord3;
    #endif

    // 顶点颜色
    float4 color;

    // 毛发数据
    float2 finUV;
    float3 finTangentWS;

    // 切线转世界空间矩阵
    float3x3 tangentToWorld;

    // 目前仅支持全屏调试下使用（在这里没有任何意义）
    uint primitiveID; 

    // 是否双面照明
    bool isFrontFace;

    // 为自定义的插值器创建一个子结构，以便正确地复制到SDI中（这个参数是 unity 底层对于曲面细分操作时使用的，但在这里没有任何意义）
    #if defined(USE_CUSTOMINTERP_SUBSTRUCT)
        CustomInterpolators customInterpolators;
    #endif

    // VFX 插值结构，最终于自定义插值合并。（但在这里也是没有任何意义，未使用）
    #if defined(HAVE_VFX_MODIFICATION)
        FragInputsVFX vfx;
    #endif
};



// 提供 Debug Display 操作
// paramId          : 材质属性索引
// input            : 片元输入结构
// result           : 按照提供 paramId 值对应的结果
// needLinearToSRGB : 是否将颜色从线性空间转换到sRGB空间
void GetVaryingsDataDebug(uint paramId, FragInputs input, inout float3 result, inout bool needLinearToSRGB)
{
    switch (paramId)
    {
    // uv
    #ifdef FRAG_INPUTS_USE_TEXCOORD0
        case DEBUGVIEWVARYING_TEXCOORD0:
            result = input.texCoord0.xyz;
            break;
    #endif
    #ifdef FRAG_INPUTS_USE_TEXCOORD1
        case DEBUGVIEWVARYING_TEXCOORD1:
            result = input.texCoord1.xyz;
            break;
    #endif
    #ifdef FRAG_INPUTS_USE_TEXCOORD2
        case DEBUGVIEWVARYING_TEXCOORD2:
            result = input.texCoord2.xyz;
            break;
    #endif
    #ifdef FRAG_INPUTS_USE_TEXCOORD3
        case DEBUGVIEWVARYING_TEXCOORD3:
            result = input.texCoord3.xyz;
            break;
    #endif
    // 切线的世界空间位置
    case DEBUGVIEWVARYING_VERTEX_TANGENT_WS:
        result = input.tangentToWorld[0].xyz * 0.5 + 0.5;
        break;
    // 副法线的世界空间位置
    case DEBUGVIEWVARYING_VERTEX_BITANGENT_WS:
        result = input.tangentToWorld[1].xyz * 0.5 + 0.5;
        break;
    // 法线的世界空间位置
    case DEBUGVIEWVARYING_VERTEX_NORMAL_WS:
        // 如果顶点数据中的法线是归一化的，则显示法线。否则，显示红色
        result = IsNormalized(input.tangentToWorld[2].xyz) ?  input.tangentToWorld[2].xyz * 0.5 + 0.5 : float3(1.0, 0.0, 0.0);
        break;
    // 顶点颜色
    case DEBUGVIEWVARYING_VERTEX_COLOR:
        result = input.color.rgb; 
        needLinearToSRGB = true;
        break;
    // 顶点颜色的 alpha 值
    case DEBUGVIEWVARYING_VERTEX_COLOR_ALPHA:
        result = input.color.aaa;
        break;
    }
}


// 画面之外的渲染
void AdjustFragInputsToOffScreenRendering(inout FragInputs input, bool offScreenRenderingEnabled, float offScreenRenderingFactor)
{
    // 重新调整 SV_POSITION 以及 像素位置
    input.positionSS.xy = offScreenRenderingEnabled ? (uint2)round(input.positionSS.xy * offScreenRenderingFactor) : input.positionSS.xy;
    input.positionPixel = offScreenRenderingEnabled ? (uint2)round(input.positionPixel * offScreenRenderingFactor) : input.positionPixel;
}


#endif //片元数据结构 | 作者：强辰