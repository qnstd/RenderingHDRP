/*
    Bloom

    渲染管线：
        High-Definition Render pipeline
    
    作者：
        强辰
*/
Shader "Hidden/Graphi/FullScreen/Bloom"
{
    HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
    #include "../../HLSL/Color.hlsl"

// /////////////////////////////////////////////////////////////
// 创建脚本时，unity自动增加的注释

    // The PositionInputs struct allow you to retrieve a lot of useful information for your fullScreenShader:
    // struct PositionInputs
    // {
    //     float4 positionWS;  // World space position (could be camera-relative)
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

// 结束
// ///////////////////////////////////////////////////////////////


    // 计算时使用的纹理
    TEXTURE2D_X(_Tex);
    float4 _Tex_TexelSize;
    float4 _Tex_ST;
    TEXTURE2D_X(_LowTex);


    /**
        参数在各个Pass下的说明
            pass0   ： x：缩放比，y：亮度提取的阔值，zw：未使用
            pass1,2 ： x：缩放比，yzw：未使用
            pass3   ： x：缩放比，y：光散值，zw：未使用
            pass4   ： xyz：颜色，w：强度
    */
    float4 _Params; 



/////////////////////////////////////////////////////////////
// 各个Pass的实现


    // 提取亮度
    float4 GetLum(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        
        // 采样像素颜色值
        float2 uv = posInput.positionNDC * _RTHandleScale.xy * _Params.x;
        float4 c = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv, 0);

        // 提取像素亮度值
        float4 lum = Lumi(c, _Params.y);

        // 若bloom所在自定义体积为local类型，摄像机接近时进行渐变。这里的bloom用于global全局，以下代码可做保留。 
        float f = 1 - abs(_FadeValue * 2 - 1);
        return float4(lum.rgb + f, lum.a);
    }


    // 高斯模糊（横）
    float4 GaussianBlurH(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

        float texel = _Tex_TexelSize.x * 2.0;
        float2 uv = posInput.positionNDC * _RTHandleScale.xy * _Params.x;

        // 采样9次
        float4 c0 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv - float2(texel * 4.0, 0.0), 0);
        float4 c1 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv - float2(texel * 3.0, 0.0), 0);
        float4 c2 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv - float2(texel * 2.0, 0.0), 0);
        float4 c3 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv - float2(texel * 1.0, 0.0), 0);
        float4 c4 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv, 0);
        float4 c5 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv + float2(texel * 1.0, 0.0), 0);
        float4 c6 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv + float2(texel * 2.0, 0.0), 0);
        float4 c7 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv + float2(texel * 3.0, 0.0), 0);
        float4 c8 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv + float2(texel * 4.0, 0.0), 0);
        
        // 根据权重计算颜色
        float4 color = c0 * 0.01621622 + c1 * 0.05405405 + c2 * 0.12162162 + c3 * 0.19459459
                    + c4 * 0.22702703
                    + c5 * 0.19459459 + c6 * 0.12162162 + c7 * 0.05405405 + c8 * 0.01621622;
        
        return color;
    }


    // 高斯模糊（纵）
    float4 GaussianBlurV(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

        float texel = _Tex_TexelSize.y;
        float2 uv = posInput.positionNDC * _RTHandleScale.xy * _Params.x;

        // 采样5次
        float4 c0 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv - float2(0.0, texel * 3.23076923), 0);
        float4 c1 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv - float2(0.0, texel * 1.38461538), 0);
        float4 c2 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv, 0);
        float4 c3 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv + float2(0.0, texel * 1.38461538), 0);
        float4 c4 = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv + float2(0.0, texel * 3.23076923), 0);
        
        float4 color = c0 * 0.07027027 + c1 * 0.31621622
                    + c2 * 0.22702703
                    + c3 * 0.31621622 + c4 * 0.07027027;

        return color;
    }


    // 升采样
    float4 Upsample(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

        float2 uv = posInput.positionNDC * _RTHandleScale.xy * _Params.x;

        float4 highMip = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv, 0);
        float4 lowMip = SAMPLE_TEXTURE2D_X_LOD(_LowTex, s_linear_clamp_sampler, uv, 0);

        // 根据光散值，对高、低模糊纹理进行插件计算
        return lerp(highMip, lowMip, _Params.y);
    }


    // 合成
    float4 CombineTex(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);

        float2 uv = posInput.positionNDC * _RTHandleScale.xy;
        
        // 对处理的模糊图进行操作
        float4 bloomcolor = SAMPLE_TEXTURE2D_X_LOD(_LowTex, s_linear_clamp_sampler, uv, 0);
        bloomcolor.xyz *= _Params.w; // 乘以强度
        bloomcolor.xyz *= _Params.xyz; // 乘以叠加颜色

        // 对源图进行操作
        float4 sourcecolor = SAMPLE_TEXTURE2D_X_LOD(_Tex, s_linear_clamp_sampler, uv, 0);

        // 合成
        return float4(sourcecolor.xyz + bloomcolor.xyz, 1.0);
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }

        ZWrite Off
        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {// 提取亮度
            Name "Graphi Bloom GetLum"
            HLSLPROGRAM
                #pragma fragment GetLum
            ENDHLSL
        }

        Pass
        {// 降采样（高斯模糊 H）
            Name "Graphi Bloom GaussianBlurH"
            HLSLPROGRAM
                #pragma fragment GaussianBlurH
            ENDHLSL
        }

        Pass
        {// 降采样（高斯模糊 V）
            Name "Graphi Bloom GaussianBlurV"
            HLSLPROGRAM
                #pragma fragment GaussianBlurV
            ENDHLSL
        }

        Pass
        {// 双线性升采样
            Name "Graphi Bloom Upsample"
            HLSLPROGRAM
                #pragma fragment Upsample
            ENDHLSL
        }

        Pass
        {// 合成（源+升降采样结果）
            Name "HGra Bloom CombineTex"
            HLSLPROGRAM
                #pragma fragment CombineTex
            ENDHLSL
        }
    }

    Fallback Off
}