/*
    摄像机镜头运动模糊

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/PostProcess/MotionBlur"
{
    Properties
    {
        _MainTex("Main Texture", 2DArray) = "grey" {} // 当前的渲染纹理
    }

    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

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


    // --透传参数
    int _Intertion; // 迭代次数
    float _Intensity; // 强度
    float _SpedFactor; // 速度差因子
    TEXTURE2D_X(_MainTex); // 当前渲染纹理
    // 计算速度差的矩阵
    float4x4 _PreviousViewProjection; 
    float4x4 _CurrentViewProjectionInverse;
    // --结束


    Varyings Vert(Attributes input)
    {
        Varyings output;

        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }


    float4 Frag_MotionBlur(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        // 计算当前像素的世界空间位置
        float2 uv = ClampAndScaleUVForBilinearPostProcessTexture(input.texcoord.xy);
        float depth = LoadCameraDepth(uv);
        float4 currentNDC = float4(uv *2-1, depth *2-1, 1.0f);
        float4 curWorldPos = mul(_CurrentViewProjectionInverse, currentNDC);
        curWorldPos /= curWorldPos.w;

        // 计算当前像素的世界空间位置在上一帧的NDC位置
        float4 previousNDC = mul(_PreviousViewProjection, curWorldPos);
        previousNDC /= previousNDC.w;

        // 计算两帧之间的NDC坐标差值（速度差）
        float2 speed = (currentNDC.xy - previousNDC.xy) / _SpedFactor;
        //return float4(length(speed), 0.0, 0.0, 1.0);

        // 根据速度计算运动模糊
        float4 c = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, uv);
        uv += speed * _Intensity;
        for(int i=1; i< _Intertion; i++, uv += speed * _Intensity)
        {
            c += SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, uv);
        }
        c /= _Intertion;

        // 后处理的alpha值必须为1
        return float4(c.rgb, 1.0);
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Graphi MotionBlur"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment Frag_MotionBlur
                #pragma vertex Vert
            ENDHLSL
        }
    }

    Fallback Off
}