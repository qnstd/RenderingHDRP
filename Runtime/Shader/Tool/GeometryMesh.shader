/*
    网格
    
    渲染管线：
        High-Definition Render pipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/Tool/GeometryMesh"
{
    Properties
    {
        [HideInInspector] _Color("color", Color) = (1,1,1,1)
        [HideInInspector] _Color2("color(unreceive light)", Color) = (1,1,1,1)
    }


    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline" 
            "Queue" = "Transparent"    
        }

        Blend One One
        ZWrite Off
        ZTest LEqual
        Cull Back

        HLSLINCLUDE
        #pragma target 4.5
        #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
        #include "../HLSL/Graphi_Color.hlsl"

        // 颜色
        float4 _Color;
         // 不受光照时的颜色
        float4 _Color2;


        // 顶点输入
        struct Attribute
        {
            float4 positionOS : POSITION;
            float3 normalOS : NORMAL;
        };
        // 顶点输出到几何渲染
        struct VtoG
        {
            float4 positionOS : POSITION;
            float3 normalOS : TEXCOORD0;
        };
        // 几何渲染输出到片元
        struct GtoF
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS : TEXCOORD0;
        };


        VtoG VS(Attribute v)
        {
            VtoG o = (VtoG)0;
            o.positionOS = v.positionOS;
            o.normalOS = v.normalOS;
            return o;
        }

        [maxvertexcount(3)]
        void GS(triangle VtoG p[3], inout LineStream<GtoF> ls)
        {
            for(int i=0; i<3; i++)
            {
                VtoG data = p[i];
                GtoF o = (GtoF)0;
                o.positionCS = TransformObjectToHClip(data.positionOS);
                o.normalWS = normalize(TransformObjectToWorldNormal(data.normalOS));
                ls.Append(o);
            }
        }

        float4 FS(GtoF i) : COLOR
        {
            return _Color;
        }
        ENDHLSL

        
        Pass
        {
            Name "Graphi - Show Geometry Mesh"
            Tags { "LightMode" = "Forward" }
            HLSLPROGRAM
            #pragma vertex VS
            #pragma geometry GS
            #pragma fragment FS
            ENDHLSL
        }
    }

    Fallback Off
}