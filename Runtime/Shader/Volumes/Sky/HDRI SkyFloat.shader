/*
    ����ת���Զ�����պ���ɫ��

    ��Ⱦ���ߣ�
        High-Definition Render Pipeline

    ���ߣ�
        ǿ��
*/
Shader "Hidden/Graphi/Sky/HDRI SkyFloat" 
{
    HLSLINCLUDE
#pragma editor_sync_compilation //��Editorģʽ��ǿ��ͬ������
#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Sky/SkyUtils.hlsl"

    //����
    TEXTURECUBE(_HDRICubemap);
    SAMPLER(sampler_HDRICubemap); 

    //͸������
    float4 _SkyParam; // x �ع�, y Ԥ��ֵ����ʱû�ã�, zw �Ƕ�
    #define _Intensity          _SkyParam.x
    #define _CosSinPhi          _SkyParam.zw


    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        UNITY_VERTEX_OUTPUT_STEREO //��������Ŀ������
    };

    

    float3 RotUp(float3 p, float2 cos_sin)
    {//�̶��ӽǵ�Y�ᣬx��z�������ת��x��z���е��������ȡ��ת����ӽ�
        float3 rotDirX = float3(cos_sin.x, 0, -cos_sin.y);  // cos(val),     0,      -sin(val)
        float3 rotDirY = float3(cos_sin.y, 0, cos_sin.x);   // sin(val),     0,      cos(val)
        return float3(dot(rotDirX, p), p.y, dot(rotDirY, p));
    }

    float4 GetColorWithRotation(float3 dir, float exposure, float2 cos_sin)
    {
        //�����������
        dir = RotUp(dir, cos_sin); 
        //����
        float3 skysample = SAMPLE_TEXTURECUBE_LOD(_HDRICubemap, sampler_HDRICubemap, dir, 0);
        //����������ع⼰�ع�ǿ�����
        float3 skyColor = skysample * _Intensity * exposure;
        skyColor = ClampToFloat16Max(skyColor);
        return float4(skyColor, 1.0);
    }


    //������Ⱦ
    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID, UNITY_RAW_FAR_CLIP_VALUE);
        return output;
    }

    //Ƭ����Ⱦ
    //input��������Ϣ
    //exposure: �ع��
    float4 RenderSky(Varyings input, float exposure)
    {
        float3 viewDirWS = GetSkyViewDirWS(input.positionCS.xy);
        float3 dir = -viewDirWS;
        return GetColorWithRotation(dir, exposure, _CosSinPhi);
    }

    //��Ⱦ����ͼ
    float4 FragBaking(Varyings input) : SV_Target
    {
        return RenderSky(input, 1.0);
    }
    //��Ⱦ���
    float4 FragRender(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        return RenderSky(input, GetCurrentExposureMultiplier());
    }


    //�������
    #pragma vertex Vert
    ENDHLSL


    SubShader
    {
        //��Ⱦ��պз�������ͼ
        Pass
        {
            ZWrite Off
            ZTest Always //��Ȳ�������ͨ��
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment FragBaking
            ENDHLSL
        }

        //��Ⱦ��պ�
        Pass
        {
            ZWrite Off
            ZTest LEqual //֧����Ȳ���
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment FragRender
            ENDHLSL
        }
    }

    Fallback Off
}