/*
    全屏灰度

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/FullScreen/Gray"
{
    HLSLINCLUDE
#pragma vertex Vert
#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
#include "../../HLSL/Graphi_Color.hlsl" 
            
        // The PositionInputs struct allow you to retrieve a lot of useful information for your fullScreenShader:
        // struct PositionInputs
        // {
        //     float3 positionWS;  // World space position (could be camera-relative)
        //     float2 positionNDC; // Normalized screen coordinates within the viewport    : [0, 1) (with the half-pixel offset)
        //     uint2  positionSS;  // Screen space pixel coordinates                       : [0, NumPixels)
        //     uint2  tileCoord;   // Screen tile coordinates                              : [0, NumTiles)
        //     float  deviceDepth; // Depth from the depth buffer                          : [0, 1] (typically reversed)
        //     float  linearDepth; // View space Z coordinate                              : [Near, Far]
        // };

        // To sample custom buffers, you have access to these functions:
        // But be careful, on most platforms you can't sample to the bound color buffer. It means that you
        // can't use the SampleCustomColor when the pass color buffer is set to custom (and same for camera the buffer).
        // float4 CustomPassSampleCustomColor(float2 uv);
        // float4 CustomPassLoadCustomColor(uint2 pixelCoords);
        // float LoadCustomDepth(uint2 pixelCoords);
        // float SampleCustomDepth(float2 uv);


        // 参数
        float4 _Params; 
        TEXTURE2D_X(_Tex);
        float4 _Tex_ST;


    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

        // 采样
        float4 c = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, posInput.positionNDC * _RTHandleScale.xy, 0);
        // 执行灰度
        c = Hue(c, _Params.x, _Params.y, _Params.z);

        // 如果是local模式的volume，则执行渐进式渲染
        float f = 1 - abs(_FadeValue * 2 - 1);
        return float4(c.rgb + f, c.a);
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Graphi FullScreen Gray"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }

    Fallback Off
}