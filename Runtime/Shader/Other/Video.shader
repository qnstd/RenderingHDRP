/*
    绘制视频

    渲染管线：
        High-Definition RenderPipeline

    作者：强辰
*/
Shader "Graphi/Unlit/Video"
{
    Properties
    {
        [HideInInspector]_MainTex("Draw Render Tex", 2D) = "white" {}

        [HideInInspector]_AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [HideInInspector]_BlendMode("_BlendMode", Range(0.0, 1.0)) = 0.5

        // 滤镜类型选取器
        [Enum(None,0,BlackWhite,1,OldPhotos,2,Relief,3,Mosaic,4)]_FilterType("Filter", float) = 0

        [Space(10)]
        _SplitBar0("", int) = 0
        [Space(10)]

        // 马赛克参数
        [Foldout]_Mosaic("Mosaic", Range(0,1)) = 0
        [To(_Mosaic)]_MosaicForce("Force", float) = 10

        // 浮雕参数
        [Foldout]_Relief("Relief", Range(0,1)) = 0
        [To(_Relief)]_level("Level", float) = 2
        [To(_Relief)]_force("Force", float) = 0.01
        [To(_Relief)][Enum(On,1,Off,0)]_invertx("Inverse x", float) = 1
        [To(_Relief)][Enum(On,1,Off,0)]_inverty("Inverse y", float) = 1
        [To(_Relief)]_rgscale("Brightness", float) = 0.25
    }

    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    // #pragma enable_d3d11_debug_symbols
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON

    ENDHLSL

    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "DrawVideo"
            Tags { "LightMode" = "Forward" }

            Blend Off
            ZWrite On
            ZTest LEqual
            Cull Back

            HLSLPROGRAM

            #define _ALPHATEST_ON

            // #define _SURFACE_TYPE_TRANSPARENT
            // #define _ENABLE_FOG_ON_TRANSPARENT
            
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            // 属性
            TEXTURE2D(_MainTex);
CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST; // 偏移缩放数据
            float4 _MainTex_TexelSize; // 纹素数据

            float _AlphaCutoff;
            float _BlendMode;

            // 滤镜类型
            float _FilterType;

            // 马赛克参数
            float _MosaicForce;

            // 浮雕参数
            float _level, _force, _rgscale;
            float _invertx, _inverty;
CBUFFER_END


            // //////////////////////////////////////////
            // 变体
            #pragma shader_feature __ _BlackWhite_On
            #pragma shader_feature __ _OldPhotos_On
            #pragma shader_feature __ _Relief_On
            #pragma shader_feature __ _Mosaic_On
            // END
            // //////////////////////////////////////////


            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"
            // 滤镜
            #include "../HLSL/Graphi-Filter.hlsl" 

           
            // 顶点处理函数
            // #define HAVE_MESH_MODIFICATION
            // AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
            // {
            //     return input;
            // }


            // 表面数据
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                float2 uv = TRANSFORM_TEX(fragInputs.texCoord0.xy, _MainTex);

                #if _Mosaic_On
                // 马赛克
                    Mosaic_float(_MainTex_TexelSize.zw, _MosaicForce, uv);
                #endif

                float4 result = SAMPLE_TEXTURE2D(_MainTex, s_trilinear_clamp_sampler, uv);
                float opacity = result.a;
                float3 color = result.rgb;


                #if _BlackWhite_On
                // 黑白图 
                    BlackWhite_float(color);
                #endif

                #if _OldPhotos_On
                // 老照片
                    OldPhotos_float(color);
                #endif 

                #if _Relief_On
                // 浮雕
                    float2 invert = float2((_invertx==0)?-1:_invertx, (_inverty==0)?-1:_inverty);
                    Relief_float(_MainTex, _MainTex_TexelSize, uv, _level, _force, _rgscale, invert, true, color);
                #endif
                


#ifdef _ALPHATEST_ON
                DoAlphaTest(opacity, _AlphaCutoff);
#endif
                // 回传数据
                ZERO_BUILTIN_INITIALIZE(builtinData); 
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = opacity;
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
    CustomEditor "com.graphi.renderhdrp.editor.VideoEditorShaderGUI"
}