/*
    热扭曲（双线性）

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Graphi/Fx/TwistDouble"
{
    Properties
    {
        [Space(10)]
        [Foldout]_TwistParams("扰动", Range(0,1)) = 1
        [Space(5)]
        [To(_TwistParams)]_TwistMap("纹理", 2D) = "white"{}
        [To(_TwistParams)]_TwistIntensity("强度", float) = 0.05
        [To(_TwistParams)]_TwistUVParams("UV", Vector) = (0,0,0,0)

        [Foldout]_SubjoinTwistParams("附加扰动", Range(0,1)) = 1
        [Space(5)]
        [To(_SubjoinTwistParams)]_ColorMap("纹理", 2D) = "white" {}
        [To(_SubjoinTwistParams)]_Intensity("强度", float) = 0.5

        [Space(10)]
        [SingleLine]_MskTex("蒙版", 2D) = "white"{}

        [HideInInspector]_AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0
        [HideInInspector]_BlendMode("_BlendMode", Range(0.0, 1.0)) = 0.5
    }

    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    //enable GPU instancing support
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    ENDHLSL

    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline"
            "RenderType" = "HDLitShader"
            "Queue" = "Transparent+350" // +350（Low ResTransparent） /  +1000 (Overlay)
            "IgnoreProjector"="True"
        }
        Pass
        {
            Name "Twist_"
            Tags { "LightMode" = "Forward" }


            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            ZTest LEqual


            HLSLPROGRAM
            #define _ALPHATEST_ON
            // #define _SURFACE_TYPE_TRANSPARENT
            // #define _ENABLE_FOG_ON_TRANSPARENT
            
            #define ATTRIBUTES_NEED_COLOR
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_CULLFACE // 需要获取正反面

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            // 纹理
            TEXTURE2D(_ColorMap);
            SAMPLER(sampler_ColorMap);
            TEXTURE2D(_TwistMap);
            SAMPLER(sampler_TwistMap);
            TEXTURE2D(_MskTex);

            // SRP 数据缓冲
            CBUFFER_START(UnityPerMaterial)
                float4 _ColorMap_ST, _TwistMap_ST, _MskTex_ST;
                float4 _TwistUVParams;
                float _Intensity, _TwistIntensity;

                float _AlphaCutoff;
                float _BlendMode;
            CBUFFER_END

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"

           
            // 设置渲染参数
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                // UV
                float2 uv = fragInputs.texCoord0.xy;
                float intensityFactor = 100;

                // 蒙版
                float msk = SAMPLE_TEXTURE2D(_MskTex, s_linear_clamp_sampler, TRANSFORM_TEX(uv, _MskTex)).r;

                // 根据扭曲UV参数，对扭曲纹理进行两次采样
                float2 _uv1 = uv + (_Time.y * _TwistUVParams.xy);
                float4 _tex1 = SAMPLE_TEXTURE2D(_TwistMap, sampler_TwistMap, TRANSFORM_TEX(_uv1, _TwistMap));
                float2 _uv2 = uv + (_Time.y * _TwistUVParams.zw);
                float4 _tex2 = SAMPLE_TEXTURE2D(_TwistMap, sampler_TwistMap, TRANSFORM_TEX(_uv2, _TwistMap));

                // 以扭曲第一次采样的r通道与第二次采样的g通道组合新的uv，并对主纹理进行采样
                float2 _uv = uv + float2(_tex1.r, _tex2.g) * (_TwistIntensity * intensityFactor);
                float4 _tex = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, TRANSFORM_TEX(_uv, _ColorMap)) * msk;

                // 采样屏幕纹理
                float2 screenUV = fragInputs.positionSS.xy + (_tex.rg * (_Intensity* intensityFactor) * _tex.a * fragInputs.color.a);
                float3 result = LoadCameraColor(screenUV);
                   

                float opacity = 1;// result.a;
                float3 color = result.rgb;

                if (Luminance(color) <= 0.001)
                {// 边缘检测（小于阔值则将透明度设置为0。防止黑边！）
                    opacity = 0;
                }

                // Alpha 测试
#ifdef _ALPHATEST_ON
                DoAlphaTest(opacity, _AlphaCutoff);
#endif

                // 渲染数据定义，并回传
                ZERO_BUILTIN_INITIALIZE(builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = opacity;
                builtinData.emissiveColor = float3(0, 0, 0);
                surfaceData.color = color;
            }

            // 渲染
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback Off
    CustomEditor "com.graphi.renderhdrp.editor.TwistDoubleEditorShaderGUI"
}