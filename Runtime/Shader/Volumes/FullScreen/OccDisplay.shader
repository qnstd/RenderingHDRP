/*
    ���ڵ���Ļ���

    ��Ⱦ���ߣ�
        High-Definition RenderPipeline

    ���ߣ�ǿ��
*/
Shader "Graphi/FullScreen/OccDisplay"
{

    Properties
    {
        [HDR]_Color("Color", Color) = (1,1,1,1)
        _Tex("Tex", 2D) = "white"{}
    }

    HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"


    
    float4 _Color; // ��ɫ
    TEXTURE2D(_Tex); // ����
    SAMPLER(sampler_Tex);
    float4 _Tex_ST;


    // ʵ��
    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        //float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        
        // ��ȡ�Զ�������ͼ����ɫ����
        float2 uv = varyings.positionCS.xy;
        float4 cc = CustomPassLoadCustomColor(uv);
        float d = LoadCustomDepth(uv);

        // ���㱻�ڵ�ʱ��ʾ����ɫ
        float alpFactor = (depth > d + 0.000001) ? 1 : 0;
        float4 oc = _Color * SAMPLE_TEXTURE2D_X_LOD(_Tex, sampler_Tex, TRANSFORM_TEX(posInput.positionNDC * _RTHandleScale.xy, _Tex), 0);
        oc.a *= alpFactor;

        // �����Զ�����ɫ�����Ժ�ɫΪ������ǰ��ɫΪ��ɫ����ô�ں������л����ɫʱ����ɫ���ֲ�������͸���ģ�����������Ҫ����ɫ����תΪ͸��.
        float factor = step(0.1, Luminance(cc.rgb));// ( c.r*c.g*c.b*c.a == 0 ) ? 0 : 1;
        cc *= factor;

        // �����ɫ
        return oc * cc;
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Occlusion Display"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}