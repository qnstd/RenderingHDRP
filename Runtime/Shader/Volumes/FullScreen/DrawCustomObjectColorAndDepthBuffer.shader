/*
    绘制自定义渲染对象的颜色缓冲及深度信息，提供遮挡显示等相关渲染功能的使用

       注意：
            1. 这里准备的颜色缓冲是以黑色为背景，前景色为白色的一张纹理；
            2. 针对非透明物体的绘制，不支持半透明物体；
            3. 绘制的颜色缓冲及深度信息是自定义纹理，在读取数据时应使用 CustomColor及CustomDepth 纹理；

    渲染管线：
        High-Definition RenderPipeline

    作者：强辰
*/
Shader "Graphi/CustomPass/DrawCustomObjectColorAndDepthBuffer"
{
    Properties
    {
        // 颜色不对外开放，内部默认使用白色作为前景色
        [HideInInspector]_Color("Color", Color) = (1,1,1,1)
    }


    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Draw CustomObject Color And Depth Buffer"
            Tags { "LightMode" = "Forward" }

            Blend Off
            Cull Back
            // 开启深度写入
            ZWrite On 
            ZTest LEqual


            HLSLPROGRAM

            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            // SRP
CBUFFER_START(UnityPerMaterial)
            float4 _Color;
CBUFFER_END

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"

            
            // 顶点变换处理
            #define HAVE_MESH_MODIFICATION
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
            {// 返回默认
                return input;
            }

            // 实现
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                // 创建构建及表面渲染数据
                ZERO_BUILTIN_INITIALIZE(builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.color = _Color.rgb;
                builtinData.opacity = _Color.a;
                builtinData.emissiveColor = float3(0, 0, 0);
            }

            // 绘制调用
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
    FallBack Off
}