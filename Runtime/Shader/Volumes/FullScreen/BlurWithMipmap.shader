/*
    静态模糊效果（轻量级模糊处理，利用颜色金字塔的Mipmap实现）

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/FullScreen/BlurWithMipmap"
{
    HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"


    // 透传参数
    float4 _RenderParam; // 渲染参数（x：mipmap级别，y：亮度因子，zw：未使用）
    // 结束

    
    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassLoadCameraColor(varyings.positionCS.xy, 0), 1);

        // 处理颜色
        //float2 pixel = posInput.positionNDC.xy * _RTHandleScale.xy;
        //color = float4( SAMPLE_TEXTURE2D_X_LOD(_ColorPyramidTexture, s_trilinear_clamp_sampler, pixel, _RenderParam.x ).rgb, 1.0 );
        color = float4(SampleCameraColor(posInput.positionNDC.xy, _RenderParam.x), 1);
        color.rgb *= _RenderParam.y;

        float f = 1 - abs(_FadeValue * 2 - 1);
        return float4(color.rgb + f, color.a);
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Graphi BlurWithMipmap"

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