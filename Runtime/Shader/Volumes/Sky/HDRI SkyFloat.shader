/*
    带旋转的自定义天空盒着色器

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/Sky/HDRI SkyFloat" 
{
    HLSLINCLUDE
#pragma editor_sync_compilation //在Editor模式下强制同步编译
#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Sky/SkyUtils.hlsl"

    //纹理
    TEXTURECUBE(_HDRICubemap);
    SAMPLER(sampler_HDRICubemap); 

    //透传参数
    float4 _SkyParam; // x 曝光, y 预乘值（暂时没用）, zw 角度
    #define _Intensity          _SkyParam.x
    #define _CosSinPhi          _SkyParam.zw


    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        UNITY_VERTEX_OUTPUT_STEREO //声明立体目标索引
    };

    

    float3 RotUp(float3 p, float2 cos_sin)
    {//固定视角的Y轴，x和z与天空旋转的x，z进行点积操作获取旋转后的视角
        float3 rotDirX = float3(cos_sin.x, 0, -cos_sin.y);  // cos(val),     0,      -sin(val)
        float3 rotDirY = float3(cos_sin.y, 0, cos_sin.x);   // sin(val),     0,      cos(val)
        return float3(dot(rotDirX, p), p.y, dot(rotDirY, p));
    }

    float4 GetColorWithRotation(float3 dir, float exposure, float2 cos_sin)
    {
        //计算采样向量
        dir = RotUp(dir, cos_sin); 
        //采样
        float3 skysample = SAMPLE_TEXTURECUBE_LOD(_HDRICubemap, sampler_HDRICubemap, dir, 0);
        //采样结果与曝光及曝光强度相乘
        float3 skyColor = skysample * _Intensity * exposure;
        skyColor = ClampToFloat16Max(skyColor);
        return float4(skyColor, 1.0);
    }


    //顶点渲染
    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID, UNITY_RAW_FAR_CLIP_VALUE);
        return output;
    }

    //片段渲染
    //input：顶点信息
    //exposure: 曝光度
    float4 RenderSky(Varyings input, float exposure)
    {
        float3 viewDirWS = GetSkyViewDirWS(input.positionCS.xy);
        float3 dir = -viewDirWS;
        return GetColorWithRotation(dir, exposure, _CosSinPhi);
    }

    //渲染立方图
    float4 FragBaking(Varyings input) : SV_Target
    {
        return RenderSky(input, 1.0);
    }
    //渲染天空
    float4 FragRender(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        return RenderSky(input, GetCurrentExposureMultiplier());
    }


    //顶点程序
    #pragma vertex Vert
    ENDHLSL


    SubShader
    {
        //渲染天空盒反射立方图
        Pass
        {
            ZWrite Off
            ZTest Always //深度测试总是通过
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment FragBaking
            ENDHLSL
        }

        //渲染天空盒
        Pass
        {
            ZWrite Off
            ZTest LEqual //支持深度测试
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment FragRender
            ENDHLSL
        }
    }

    Fallback Off
}