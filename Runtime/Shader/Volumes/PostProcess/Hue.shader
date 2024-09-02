/*
    后处理 - Hue

    渲染管线：High-Definition Render Pipeline

    作者：强辰
*/
Shader "Hidden/Graphi/PostProcess/Hue"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    #include "../../HLSL/Graphi_Color.hlsl"


    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        //获取全屏像素所在的裁剪空间坐标
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        //获取全屏UV坐标
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        
        return output;
    }


//参数
    float _Brightness;
    float _Saturation;
    float _Contrast;
    TEXTURE2D_X(_SourceTex);
//END


    float4 HueFrag(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        //采样颜色
        //ClampAndScaleUVForBilinearPostProcessTexture 执行动态分辨率适配
        float3 sourceColor = SAMPLE_TEXTURE2D_X(_SourceTex, s_linear_clamp_sampler, ClampAndScaleUVForBilinearPostProcessTexture(input.texcoord.xy)).xyz;
        
        // 执行HUE操作
        float4 result = Hue(float4(sourceColor,1), _Brightness, _Saturation, _Contrast);

        return float4(result.rgb, 1); //自定义后处理，返回颜色值的Alpha通道必须是1
    }

    ENDHLSL

    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "HuePostProcess"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment HueFrag
                #pragma vertex Vert
            ENDHLSL
        }
    }

    //Fallback
    Fallback Off
}
