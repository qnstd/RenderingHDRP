/*
    通过高度图或漫反射图构建法线图

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/Tool/NormalTextureBuild"
{
    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="HDRenderPipeline"
            "PreviewType" = "Plane"
        }

        
//Include
        HLSLINCLUDE
        #pragma target 4.5
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

        // 滤镜
        #include "../HLSL/Filter.hlsl" 


        //源纹理数据
        TEXTURE2D(_BlitTexture);
        float4 _BlitTexture_TexelSize; //纹素（1/w, 1/h)

        float _Level; //偏移幅度
        float _Strength; //强度
        float4 _Invert; //x、y轴是否翻转
        int _Flgorithm; //计算法线的算法类型
        float _RGScale; //R、G通道缩放


        // 顶点输入
        #if SHADER_API_GLES
        struct Attributes
        {
            float4 positionOS       : POSITION;
            float2 uv               : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };
        #else
        struct Attributes
        {
            uint vertexID : SV_VertexID;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };
        #endif

        // 顶点输出
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float2 texcoord   : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };


        // 顶点着色
        Varyings Vert(Attributes input)
        {
            Varyings output;
            UNITY_SETUP_INSTANCE_ID(input);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
     
            #if SHADER_API_GLES
                float4 pos = input.positionOS;
                float2 uv  = input.uv;
            #else
                float4 pos = GetFullScreenTriangleVertexPosition(input.vertexID);
                float2 uv  = GetFullScreenTriangleTexCoord(input.vertexID);
            #endif
            output.positionCS = pos;
            output.texcoord   = uv;

            return output;
        }



        //计算法线算法类型 -Sobel
        float3 Transfer_Sobel(float2 uv)
        {
            float3 N = 0;
            Relief_float(_BlitTexture, _BlitTexture_TexelSize, uv, _Level, _Strength, _RGScale, _Invert.xy, false, N);
            return N;
        }
        

        // 片元着色
        float4 Frag(Varyings input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            float3 N = float3(0, 0, 0);
            if (_Flgorithm == 0) 
            {//Sobel算法
                N = Transfer_Sobel(input.texcoord);
            }

            return float4(N, 1);
            //return SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, s_linear_clamp_sampler, input.texcoord.xy, 0);
        }
        ENDHLSL


//Pass 
        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback Off
}