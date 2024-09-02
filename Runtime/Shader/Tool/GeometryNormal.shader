/*
    顶点法线
    
    渲染管线：
        High-Definition Render pipeline

    作者：
        强辰
*/
Shader "Hidden/Graphi/Tool/GeometryNormal"
{
    Properties
    {
        [HideInInspector][Enum(WS,1,VS,2)]_SpaceType("空间", float) = 1
        [HideInInspector] _Color("颜色", Color) = (1,1,1,1)
        [HideInInspector] _Color2("颜色（不受光照区域）", Color) = (1,1,1,1)
        [HideInInspector] _Length("长度", float) = 1
    }


    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline" 
            "Queue" = "Transparent"    
            "IgnoreProjector" = "True"
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
        // 长度
        float _Length;
        // 空间类型
        float _SpaceType;



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
            float3 N : TEXCOORD0;
        };


        VtoG VS(Attribute v)
        {
            VtoG o = (VtoG)0;
            o.positionOS = v.positionOS;
            o.normalOS = v.normalOS;
            return o;
        }

        [maxvertexcount(2)]
        void GS(point VtoG p[1], inout LineStream<GtoF> ls)
        {
            VtoG data = p[0];
            float4 pos = data.positionOS;
            float3 n = data.normalOS;
            float3 wn = TransformObjectToWorldNormal(n);
            float3 vn = normalize(TransformWorldToViewNormal(wn));
            float3 _N = (_SpaceType == 1) ? wn : ((_SpaceType == 2) ? vn : wn);

            GtoF o1 = (GtoF)0;
            o1.positionCS = TransformObjectToHClip(pos);
            o1.N = _N;
            ls.Append(o1);

            GtoF o2 = (GtoF)0;
            o2.positionCS = TransformObjectToHClip(pos + float4(n * _Length, 0));
            o2.N = _N;
            ls.Append(o2);
        }

        float4 FS(GtoF i) : COLOR
        {
            return float4(i.N, 1);
        }
        ENDHLSL

        
        Pass
        {
            Name "Graphi - Show Vertex Normal"
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