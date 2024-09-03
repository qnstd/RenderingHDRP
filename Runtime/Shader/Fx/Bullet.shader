/*
    特效（子弹）着色器

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Graphi/Fx/Bullet"
{
    Properties
    {
        [Space(15)]
        [HDR]_Color("Color", Color) = (1,1,1,1)
        _MainTex("Tex", 2D) = "white"{}
        _Size("Size", Float) = 0.2
        _Offset("Offset", Float) = 0

        [Space(10)]
        _InvFade("Fade", Float) = 1.0

        [HideInInspector]_AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0
        [HideInInspector]_BlendMode("_BlendMode", Range(0.0, 1.0)) = 0.5
    }

    // Include
    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    // GPU 支持
    #pragma multi_compile_instancing
    // ECS 混合渲染
    #pragma multi_compile _ DOTS_INSTANCING_ON
    ENDHLSL


    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline" 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
        }

        Pass
        {
            Name "Graphi Fx Bullet"
            Tags { "LightMode" = "Forward" }

            Blend SrcAlpha One
            ColorMask RGB
            Cull Off
            ZTest LEqual
            ZWrite Off

            HLSLPROGRAM
            // 开启AlphaTest
            #define _ALPHATEST_ON
            // 开启透明
            #define _SURFACE_TYPE_TRANSPARENT
            // 开启透明情况下的雾混合
            #define _ENABLE_FOG_ON_TRANSPARENT
            
            // 设置请求顶点数据
            #define ATTRIBUTES_NEED_TEXCOORD0 // 第1套UV用于采样
            //#define ATTRIBUTES_NEED_TEXCOORD1 // 这里的第2套UV用于存储其他数据，并非用来做第2套UV进行采样
            #define ATTRIBUTES_NEED_COLOR // 顶点颜色

            #define VARYINGS_NEED_TEXCOORD0 // 第1套UV用于采样
            //#define VARYINGS_NEED_TEXCOORD1 // 这里的第2套UV用于存储其他数据，并非用来做第2套UV进行采样
            #define VARYINGS_NEED_COLOR // 顶点颜色
            //#define VARYINGS_NEED_POSITION_WS // 必须开启相对摄像机的世界空间坐标计算，否则后续操作会发生异常

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            // 纹理
            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

            // 数据缓冲
CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _Color;
            float _Size, _Offset, _InvFade;

            float _AlphaCutoff;
            float _BlendMode;
CBUFFER_END

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"


            // 几何变换
            //[maxvertexcount(3)]
            //void Geom(triangle PackedVaryingsMeshToPS input[3], inout TriangleStream<PackedVaryingsMeshToPS> outputStream)
            //{
            //    float lineLength = length(input[2].interpolators0 - input[0].interpolators0); //interpolators0: 为相对摄像机的世界坐标
            //    for(int i=0; i<3; i++)
            //    {
            //        PackedVaryingsMeshToPS o;
            //        o = input[i];
            //        o.interpolators3.z = lineLength; //因为开启第2套UV，此数据用于存储特殊数据，并非是用来采样的第2套UV
            //        outputStream.Append(o);
            //    } 
            //}
            

            // 组织表面数据
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                //float times = fragInputs.texCoord1.x/ _Size;
                float times = 1 / _Size;

                float4 uvTrans = _MainTex_ST;
                uvTrans.x *= times;
                float2 uv = fragInputs.texCoord0.xy * uvTrans.xy + uvTrans.zw;
                uv.x = saturate(uv.x + _Offset * (times+1));
                uv.y = saturate(uv.y);
                 
                float4 c = fragInputs.color * _Color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

                // 交叉软化
                float scnZ = LinearEyeDepth(LoadCameraDepth(fragInputs.positionSS.xy), _ZBufferParams);
                float objZ = fragInputs.positionSS.w;
                float fade = saturate(_InvFade * (scnZ - objZ));
                c.a *= fade;

                float opacity = c.a;
                float3 color = c.rgb;

#ifdef _ALPHATEST_ON
                DoAlphaTest(opacity, _AlphaCutoff);
#endif

                // 返回数据
                ZERO_BUILTIN_INITIALIZE(builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = opacity;
                builtinData.emissiveColor = float3(0, 0, 0);
                surfaceData.color = color;
            }

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            //#pragma geomtry Geom
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback "Hidden/Graphi/FallbackErr"
}