/*
    ���� - Hue

    ��Ⱦ���ߣ�High-Definition Render Pipeline

    ���ߣ�ǿ��
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

        //��ȡȫ���������ڵĲü��ռ�����
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        //��ȡȫ��UV����
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        
        return output;
    }


//����
    float _Brightness;
    float _Saturation;
    float _Contrast;
    TEXTURE2D_X(_SourceTex);
//END


    float4 HueFrag(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        //������ɫ
        //ClampAndScaleUVForBilinearPostProcessTexture ִ�ж�̬�ֱ�������
        float3 sourceColor = SAMPLE_TEXTURE2D_X(_SourceTex, s_linear_clamp_sampler, ClampAndScaleUVForBilinearPostProcessTexture(input.texcoord.xy)).xyz;
        
        // ִ��HUE����
        float4 result = Hue(float4(sourceColor,1), _Brightness, _Saturation, _Contrast);

        return float4(result.rgb, 1); //�Զ������������ɫֵ��Alphaͨ��������1
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
