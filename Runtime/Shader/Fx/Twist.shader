/*
    热扭曲

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Graphi/Fx/Twist"
{
    Properties
    {
        //噪声
        [Foldout] _NoiseOperate("Noise",Range(0,1)) = 1
        [Space(5)]
        [To(_NoiseOperate)]_NoiseTex("Tex", 2D) = "white" {}
        [To(_NoiseOperate)]_NoiseRot("Rotation", Range(0,360)) = 0

        //遮罩
        [Space(10)]
        [Foldout]_MaskOperate("Mask",Range(0,1)) = 1
        [Space(5)]
        [To(_MaskOperate)]_MaskTex("Tex", 2D) = "white"{}
        [To(_MaskOperate)]_MaskRot("Rotation", Range(0,360)) = 0

        [Space(10)]
        [Foldout]_PublicProp("Public", Range(0,1)) = 1
        [Space(5)]
        [To(_PublicProp)]_Force("Force", float) = 0.1
        [To(_PublicProp)]_UVParams("UV speed", Vector) = (0, 0, 0, 0)
        //[To(_PublicProp)]_VertexAlpha("Vertex Alpha", Range(0,1)) = 1 // 模拟顶点颜色的alpha值
    }


//HLSL Include
    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    // #pragma enable_d3d11_debug_symbols
    #pragma multi_compile_instancing // GPU Instance 支持
    #pragma multi_compile _ DOTS_INSTANCING_ON // DOTS 支持
    ENDHLSL


    SubShader
    {
        Tags
        {
            "RenderPipeline" = "HDRenderPipeline"
            "RenderType" = "HDLitShader"
            "Queue" = "Transparent+350"//Low ResTransparent 
        }


        Pass
        {
            Name "Graphi-Twist"
            Tags { "LightMode" = "Forward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual //Always
            Cull Off


            HLSLPROGRAM
             //#define _SURFACE_TYPE_TRANSPARENT //开启透明模式
            // #define _ENABLE_FOG_ON_TRANSPARENT //开启雾
            
            // 顶点数据获取
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_COLOR
            // 顶点变种数据获取
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_COLOR

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
//纹理
TEXTURE2D(_NoiseTex);
SAMPLER(sampler_NoiseTex);
TEXTURE2D(_MaskTex);
SAMPLER(sampler_MaskTex);

//SRP
CBUFFER_START(UnityPerMaterial)
float4 _NoiseTex_ST, _MaskTex_ST;
float _MaskRot, _NoiseRot, _Force;
float4 _UVParams;
//float _VertexAlpha;
CBUFFER_END

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"
#include "../HLSL/Graphi_Transformation.hlsl"

//顶点变换操作函数
             #define HAVE_MESH_MODIFICATION
             AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
             {
                 //input.positionOS += input.normalOS * 0.0001;
                 return input; 
             }
            
//片段操作
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                float2 uv = fragInputs.texCoord0.xy;
                float2 pivot = float2(0.5, 0.5);

                // 计算遮罩、噪声图采样坐标
                float2 uvNoise = TRANSFORM_TEX(uv, _NoiseTex);
                pivot *= _NoiseTex_ST.xy;
                pivot += _NoiseTex_ST.zw;
                UVRot(_NoiseRot, pivot, uvNoise);
                uvNoise += _UVParams.xy * _Time.y;

                float2 uvMask = TRANSFORM_TEX(uv, _MaskTex);
                pivot = float2(0.5, 0.5);
                pivot *= _MaskTex_ST.xy;
                pivot += _MaskTex_ST.zw;
                UVRot(_MaskRot, pivot, uvMask);
                uvMask += _UVParams.zw * _Time.y;

                // 采样
                float4 _NoiseTex_var = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uvNoise);
                float4 _MaskTex_var = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uvMask);

                // 计算折射采样坐标
                float4 vertexColor = fragInputs.color;
                float vertexColorAlpha = vertexColor.a; // _VertexAlpha
                float2 screenUVs = fragInputs.positionSS.xy + (lerp(_NoiseTex_var.rgb, _MaskTex_var.rgb, vertexColorAlpha) * (vertexColorAlpha * (_Force * 100))).xy;
               
                // 采样
                float3 color = LoadCameraColor(screenUVs);

                //数据回传
                ZERO_BUILTIN_INITIALIZE(builtinData); 
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = 1;
                builtinData.emissiveColor = float3(0, 0, 0);
                surfaceData.color = color;
            }

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }


Fallback "Hidden/Graphi/FallbackErr"
CustomEditor "com.graphi.renderhdrp.editor.TwistEditorShaderGUI"
}