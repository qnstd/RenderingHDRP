/*
    ��ͨ���߶�ͼ��������ͼ�����ķ���ͼ����ģ������

    ��Ⱦ���ߣ�
        High-Definition Render Pipeline

    ���ߣ�
        ǿ��
*/
Shader "Hidden/Graphi/Tool/NormalTextureBlur"
{
    SubShader
    {
        Tags
        { 
            "RenderPipeline"="HDRenderPipeline"
            "PreviewType" = "Plane"
        }


        HLSLINCLUDE
        #pragma target 4.5
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

        // Դ����
        TEXTURE2D(_BlitTexture);
        float4 _BlitTexture_TexelSize;
        // ģ����
        float _Blur;


        // ��������
        #if SHADER_API_GLES
            struct Attribute
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
        #else
            struct Attribute
            {
                uint vertexID : SV_VertexID;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
        #endif

        // �������
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float2 uv[5] : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };


        // ������ɫ��
        void Vert(int dir, Attribute input, inout Varyings output)
        {
            #if SHADER_API_GLES
                float4 pos = input.positionOS;
                float2 uv  = input.uv;
            #else
                float4 pos = GetFullScreenTriangleVertexPosition(input.vertexID);
                float2 uv  = GetFullScreenTriangleTexCoord(input.vertexID);
            #endif

            output.positionCS = pos;
            output.uv[0] = uv;

            if(dir == 1)
            {
                output.uv[1] = uv + float2(_BlitTexture_TexelSize.x * 1.0, 0.0) * _Blur;
                output.uv[2] = uv - float2(_BlitTexture_TexelSize.x * 1.0, 0.0) * _Blur;
                output.uv[3] = uv + float2(_BlitTexture_TexelSize.x * 2.0, 0.0) * _Blur;
                output.uv[4] = uv - float2(_BlitTexture_TexelSize.x * 2.0, 0.0) * _Blur;
            }
            else
            {
                output.uv[1] = uv + float2(0.0, _BlitTexture_TexelSize.y * 1.0) * _Blur;
                output.uv[2] = uv - float2(0.0, _BlitTexture_TexelSize.y * 1.0) * _Blur;
                output.uv[3] = uv + float2(0.0, _BlitTexture_TexelSize.y * 2.0) * _Blur;
                output.uv[4] = uv - float2(0.0, _BlitTexture_TexelSize.y * 2.0) * _Blur;
            }
        }

        // �������
        float3 SampleTex(float2 uv, float weight)
        {
            return SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, s_linear_clamp_sampler, uv, 0).rgb * weight;
        }


        // ����ģ��
        Varyings VertV(Attribute input)
        {
            Varyings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

            Vert(0, input, output);
            return output;
        }
        // ����ģ��
        Varyings VertH(Attribute input)
        {
            Varyings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
            
            Vert(1, input, output);
            return output;
        }
        // ƬԪ��ɫ��
        float4 Frag(Varyings input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            //Ȩ��
            float weight[3] = {0.4026, 0.2442, 0.0545}; 
            
            float3 color = SampleTex(input.uv[0], weight[0]);
            for (int indx = 1; indx < 3; indx++) 
            {
                float wei = weight[indx];
                color += SampleTex(input.uv[indx * 2 - 1], wei);
                color += SampleTex(input.uv[indx * 2], wei);
            }

            return float4(color, 1);
        }
        ENDHLSL

        
////////////////////////////////////////////////////////
// Pass :

//����ģ������
        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off
            HLSLPROGRAM
            #pragma vertex VertV
            #pragma fragment Frag
            ENDHLSL
        }
//����ģ������
        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off
            HLSLPROGRAM
            #pragma vertex VertH
            #pragma fragment Frag
            ENDHLSL
        }

// END
////////////////////////////////////////////////////////
    }

    Fallback Off
}