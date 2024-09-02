/*
    �����Զ�����Ⱦ�������ɫ���弰�����Ϣ���ṩ�ڵ���ʾ�������Ⱦ���ܵ�ʹ��

       ע�⣺
            1. ����׼������ɫ�������Ժ�ɫΪ������ǰ��ɫΪ��ɫ��һ������
            2. ��Է�͸������Ļ��ƣ���֧�ְ�͸�����壻
            3. ���Ƶ���ɫ���弰�����Ϣ���Զ��������ڶ�ȡ����ʱӦʹ�� CustomColor��CustomDepth ����

    ��Ⱦ���ߣ�
        High-Definition RenderPipeline

    ���ߣ�ǿ��
*/
Shader "Graphi/CustomPass/DrawCustomObjectColorAndDepthBuffer"
{
    Properties
    {
        // ��ɫ�����⿪�ţ��ڲ�Ĭ��ʹ�ð�ɫ��Ϊǰ��ɫ
        [HideInInspector]_Color("Color", Color) = (1,1,1,1)
    }


    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Draw CustomObject Color And Depth Buffer"
            Tags { "LightMode" = "Forward" }

            Blend Off
            Cull Back
            // �������д��
            ZWrite On 
            ZTest LEqual


            HLSLPROGRAM

            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            // SRP
CBUFFER_START(UnityPerMaterial)
            float4 _Color;
CBUFFER_END

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"

            
            // ����任����
            #define HAVE_MESH_MODIFICATION
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
            {// ����Ĭ��
                return input;
            }

            // ʵ��
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                // ����������������Ⱦ����
                ZERO_BUILTIN_INITIALIZE(builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.color = _Color.rgb;
                builtinData.opacity = _Color.a;
                builtinData.emissiveColor = float3(0, 0, 0);
            }

            // ���Ƶ���
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
    FallBack Off
}