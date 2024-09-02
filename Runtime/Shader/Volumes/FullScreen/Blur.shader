/*
    自定义全屏模糊处理

    渲染管线：HDRP

    作者：强辰
*/
Shader "Hidden/Graphi/FullScreen/Blur"
{
    HLSLINCLUDE

#pragma vertex Vert

#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

// ////////////////////////////////////////////////////////////////////////////////
// 这里是Unity在创建全屏渲染着色器文件时默认添加的注释，但此效果不需要他提示里边的内容。
// 
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
        // 
        // float4 CustomPassSampleCustomColor(float2 uv);
        // float4 CustomPassLoadCustomColor(uint2 pixelCoords);
        // float LoadCustomDepth(uint2 pixelCoords);
        // float SampleCustomDepth(float2 uv);

        // There are also a lot of utility function you can use inside Common.hlsl and Color.hlsl,
        // you can check them out in the source code of the core SRP package.
//
// END
// ///////////////////////////////////////////////////////////////////////////////////
// 
// 
    
    // 纹理
    TEXTURE2D_X(_SourceTex);
    // 模糊值
    float _Blur;
    // 目标纹理的缩放比
    float _Scal;
    // 附加纹理
    TEXTURE2D(_STex);
    // 附加纹理的强度
    float _Intensity;
    // 反向
    int _Reverse;


    //采样
    float4 SamplerSourceTex(float2 uv, float weight)
    {
        return SAMPLE_TEXTURE2D_X_LOD(_SourceTex, s_linear_clamp_sampler, uv, 0) * weight;
    }

    //模糊处理
    float4 Blur(PositionInputs posInput, int dir/*1:V，0:H*/)
    {
        float2 uv = posInput.positionNDC * _RTHandleScale.xy * _Scal;
        float4 c = SamplerSourceTex(uv, 1);

        //模糊处理
        float4 final = c;
        final.a = 0;
        if (Luminance(c.rgb) > 0)
        {
            float weight[3] = { 0.4026, 0.2442, 0.0545 }; //权重
            float3 c3 = c.rgb * weight[0];
            float _weight;
            for (int i = 1; i < 3; i++)
            {
                _weight = weight[i];
                if (dir == 1)
                {// 纵向
                    c3 += SamplerSourceTex(uv + float2(0, _ScreenSize.w * i * _RTHandleScale.y) * _Blur, _weight);
                    c3 += SamplerSourceTex(uv - float2(0, _ScreenSize.w * i * _RTHandleScale.y) * _Blur, _weight);
                }
                else
                {// 横向
                    c3 += SamplerSourceTex(uv + float2(_ScreenSize.z * i * _RTHandleScale.x, 0) * _Blur, _weight);
                    c3 += SamplerSourceTex(uv - float2(_ScreenSize.z * i * _RTHandleScale.x, 0) * _Blur, _weight);
                }
            }
            final.rgb = c3;
            final.a = 1;
        }
        return final;
    }

    //纵向
    float4 BlurV(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        // 如果没有在BeforeRendering节点前渲染，将摄像机当前的颜色缓冲加载到mip0中
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassLoadCameraColor(varyings.positionCS.xy, 0), 1);

        return  Blur(posInput, 1);
    }

    //横向
    float4 BlurH(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        // 如果没有在BeforeRendering节点前渲染，将摄像机当前的颜色缓冲加载到mip0中
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassLoadCameraColor(varyings.positionCS.xy, 0), 1);

        return  Blur(posInput, 0);
    }

    // 附加纹理
    float4 SpecialTexDeal(Varyings varyings) : SV_Target
    {
         UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

        // uv
        float2 uv = posInput.positionNDC * _RTHandleScale.xy * _Scal;

        // 采样法线图
        float4 stex = SAMPLE_TEXTURE2D_X_LOD(_STex, s_linear_clamp_sampler, uv, 0);
        float3 tnormal = UnpackNormalScale(stex, _Intensity); // 切线空间的法线值
        tnormal.xy *= _Reverse;

        // 应用采样后的法线并返回
        return SamplerSourceTex(uv + tnormal.xy, 1);;
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }

        ZWrite Off
        ZTest Always
        Blend Off 
        Cull Off

        Pass
        {
            Name "Graphi FullsBlur V"
            HLSLPROGRAM
                #pragma fragment BlurV
            ENDHLSL
        }
        Pass
        {
            Name "Graphi FullsBlur H"
            HLSLPROGRAM
                #pragma fragment BlurH
            ENDHLSL
        }
        Pass
        {
            Name "Graphi FullsBlur SpecialTexDeal"
            HLSLPROGRAM
                #pragma fragment SpecialTexDeal
            ENDHLSL
        }
    }

    Fallback Off
}