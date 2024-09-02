/*
    热扭曲（支持顶点偏移变换）

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Graphi/Fx/TwistVert"
{
    Properties
    {
        [Foldout] _TwistOperate("热扭曲（Twist）",Range(0,1)) = 1
        [Space(5)]
        [To(_TwistOperate)]_MainTex("纹理", 2D) = "white" {}
        [SingleLine][To(_TwistOperate)]_MskTex("蒙版", 2D) = "white"{}
        [To(_TwistOperate)]_Intensity("强度", Float) = 0

        [Space(10)]
        [Foldout] _VertexOperate("顶点偏移（Vertex Offset）",Range(0,1)) = 0
        [Space(5)]
        [To(_VertexOperate)]_VertexTex("偏移纹理", 2D) = "white" {}
        [To(_VertexOperate)]_Nor("法线偏移因子", Float) = 0

        [Space(10)]
        [Foldout] _Pub("公共属性（Public）",Range(0,1)) = 1
        [To(_Pub)]_UVParams("UV 偏移设置", Vector) = (0, 0, 0, 0)

        [HideInInspector]_AlphaCutoff("Alpha 裁剪", Range(0.0, 1.0)) = 0
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
        }

        Pass
        {
            Name "Graphi-TwistVert"
            Tags { "LightMode" = "Forward" }


            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            ZTest LEqual


            HLSLPROGRAM

            #define _ALPHATEST_ON // 开启alphatest
            //#define _SURFACE_TYPE_TRANSPARENT // 开启透明
            //#define _ENABLE_FOG_ON_TRANSPARENT  // 开启雾混合
            
            // 请求顶点参数
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
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_VertexTex);
            SAMPLER(sampler_VertexTex);
            TEXTURE2D(_MskTex);
            SAMPLER(sampler_MskTex);

        // 数据缓冲
CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _VertexTex_ST;
            float4 _MskTex_ST;
            float4 _UVParams;
            float _Intensity, _Nor;
            float _AlphaCutoff;
            float _BlendMode;
CBUFFER_END


            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"

            // 修改模型空间下的顶点坐标
             #define HAVE_MESH_MODIFICATION
             AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
             {
                 float2 vertexUVOffset = input.uv0.xy + (_Time.g * _UVParams.zw);
                 float4 samplers = SAMPLE_TEXTURE2D_X_LOD(_VertexTex, sampler_VertexTex, TRANSFORM_TEX(vertexUVOffset, _VertexTex), 0);
                 input.positionOS.xyz += (input.normalOS * _Nor * samplers.x);
                 return input;
             }


            // 渲染
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                float3 normalWS = fragInputs.tangentToWorld[2]; // 世界法线（归一化）
                normalWS *= ((fragInputs.isFrontFace) ? 1 : -1);
                float3 view = normalize(GetCameraRelativePositionWS(_WorldSpaceCameraPos) - fragInputs.positionRWS); // 视角方向

                // 采样扭曲纹理及扭曲遮罩纹理
                float msk = SAMPLE_TEXTURE2D(_MskTex, s_linear_clamp_sampler , TRANSFORM_TEX(fragInputs.texCoord0.xy, _MskTex)).r;
                float2 twistUV = fragInputs.texCoord0.xy + (_Time.g * _UVParams.xy);
                float4 twistSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(twistUV, _MainTex)) * msk;

                // 最终采样
                float2 screenUV = fragInputs.positionSS.xy + (twistSample.rg * (_Intensity * 100) * twistSample.a * fragInputs.color.a);
                float3 result = LoadCameraColor(screenUV);

                float3 c = result.rgb;
                float opacity = 1;// result.a;

                if (Luminance(c) <= 0.001)
                {// 边缘检测（小于阔值则将透明度设置为0。防止黑边！）
                    opacity = 0;
                }

                
#ifdef _ALPHATEST_ON
                // alpha 测试
                DoAlphaTest(opacity, _AlphaCutoff);
#endif

                // 创建渲染数据并回传
                ZERO_BUILTIN_INITIALIZE(builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.color = c;
                builtinData.opacity = opacity;
                builtinData.emissiveColor = float3(0, 0, 0);
            }

            // 渲染程序
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback Off
    CustomEditor "com.graphi.renderhdrp.editor.TwistVertEditorShaderGUI"
}