/*
    径向模糊 - 后处理

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/FullScreen/RadialBlur"
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

    // There are also a lot of utility function you can use inside Common.hlsl and Color.hlsl,
    // you can check them out in the source code of the core SRP package.


    TEXTURE2D_X(_Tex);
    float _ScaleBias; // 缩放比
    float4 _Params; //xy: 径向模糊的中心点，z：模糊强度，w：迭代次数


    // 径向模糊
    float4 RBlur(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        
        float4 c = float4(0,0,0,0);
        
        float scal = _RTHandleScale.xy * _ScaleBias;
        float2 uv = posInput.positionNDC.xy * scal; // 计算当前像素UV
        float2 center = _Params.xy * scal; // 径向模糊中心点
        float intensity = _Params.z; // 强度
        float iters = _Params.w; // 迭代次数

        // 模糊处理
        float2 step = (center - uv) * intensity * 0.01;
        for(int i=0; i<iters; i++)
        {
            c += SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv + step * i, 0);
        }
        c /= iters;

        // 返回颜色
        float f = 1 - abs(_FadeValue * 2 - 1);
        return float4(c.rgb + f, c.a);
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {// 模糊处理通道
            Name "Graphi Radial Blur"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment RBlur 
            ENDHLSL
        }
    }

    Fallback Off
}