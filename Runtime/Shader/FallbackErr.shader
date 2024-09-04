/**
    着色器Fallback
    
    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/FallbackErr"
{
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma target 4.5

            #pragma multi_compile _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON

            // 强制在编辑器模式下同步编译
            #pragma editor_sync_compilation 

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

            #include "./HLSL/Color.hlsl"


            struct a2v
            {
                float4 positionOS : POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO    
            };


            v2f Vert (a2v v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.positionCS = TransformObjectToHClip(v.positionOS);
                o.uv0 = v.uv0;
                return o;
            }

            float4 Frag (v2f i) : SV_Target
            {
                float tile = 10;
                float2 uv = frac(i.uv0  * tile);
                float4 c = float4(uv, 0, 1);
                return lerp(
                            float4(191/255.0, 47/255.0, 47/255.0, 1), 
                            float4(0, 0, 0, 1), 
                            Gray(c.rgb).x
                        );
            }

            // 渲染
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback Off
}