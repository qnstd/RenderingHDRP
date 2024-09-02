/*
    全屏渲染 - 描边

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/FullScreen/Edges"
{
    HLSLINCLUDE

#pragma vertex Vert

#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

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

    // 透传参数
    float _Threshold; // 亮度阔值
    float4 _Color; // 描边颜色
    float _Width; // 描边宽度
    TEXTURE2D_X(_Tex); // 参与描边对象的纹理
    

    // 常量
    #define MAX_NUM 8
    static float2 _Samples[MAX_NUM] =
    {
        float2(1,  1),
        float2(0,  1),
        float2(-1,  1),
        float2(-1,  0),
        float2(-1, -1),
        float2(0, -1),
        float2(1, -1),
        float2(1, 0),
    };


    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
       
        // 优化亮度阔值
        float threshold = max(0.000001, _Threshold * 0.01);

        // 采样参与描边的对象纹理
        float2 uv = posInput.positionNDC.xy * _RTHandleScale.xy;
        float4 edges = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv, 0);
        edges.a = 0;

        // 根据亮度值、周围像素采样确定边界
        if (Luminance(edges.rgb) < threshold)
        {
            for (int i = 0; i < MAX_NUM; i++)
            {
                float2 _uv = uv + _ScreenSize.zw * _RTHandleScale.xy * _Samples[i] * _Width;
                float4 _around = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, _uv, 0);
                if (Luminance(_around.rgb) > threshold)
                {
                    edges.rgb = _Color.rgb;
                    edges.a = 1.0;
                    break;
                }
            }
        }

        return edges;
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Graphi Edges"

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