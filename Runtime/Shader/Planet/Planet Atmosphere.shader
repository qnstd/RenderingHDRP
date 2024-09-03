/**
    星球 - 大气层平行光散射

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Graphi/Planet/Atmosphere"
{
    Properties
    {
        // 基础
        [Foldout]_BaseParams("Vertex、UV Offset", Range(0,1))=1
        [Space(5)]
        [To(_BaseParams)]_VertexOffset("Vertex Offset", Float) = 0
		[To(_BaseParams)]_UVOffset("UV Offset", Float) = 0

        // 散射
        [Space(10)]
        [Foldout]_ScatterParams("Scatter", Range(0,1))=1
        [Space(5)]
        [To(_ScatterParams)][SingleLine]_AtmosphereTex("Tex", 2D) = "black" {}
		[To(_ScatterParams)]_ScatteringOffset("Offset", Float) = 0
		[To(_ScatterParams)][HDR]_ScatteringColor("Color", Color) = (0,0,0,0)
		[To(_ScatterParams)]_ScatteringIntensity("Force", Float) = 0
		[To(_ScatterParams)]_ScatteringFactor("Factor", Float) = 0

        // 发光
        [Space(10)]
        [Foldout]_GlowParams("Glow", Range(0,1))=1
        [Space(5)]
		[To(_GlowParams)]_GlowOffset("Offset", Float) = 0
		[To(_GlowParams)][HDR]_GlowColor("Color", Color) = (0,0,0,0)
		[To(_GlowParams)]_GlowIntensity("Force", Float) = 0
		[To(_GlowParams)]_GlowFactor("factor", Float) = 0

        // 主光
		[Space(10)]
        [Foldout]_SunParams("DirectionalLight", Range(0,1))=1
        [Space(5)]
		[To(_SunParams)]_LightSensitivity("Sensitivity", Float) = 0
		[To(_SunParams)]_LightPow("Pow", Float) = 0
        [To(_SunParams)][MaterialToggle]_LightAtten("Atten", Float) = 0

        // Hide
        [HideInInspector]_BlendMode("_BlendMode", Range(0.0, 1.0)) = 0.5
    }

//HLSL Include 
    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    // GPU
    #pragma multi_compile_instancing
    // DOTs ECS
    #pragma multi_compile _ DOTS_INSTANCING_ON
    ENDHLSL

    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline" 
            "Queue" = "Transparent"    
            "PreviewType" = "Sphere"
        }

        Pass
        {
            Name "Graphi - Planet Atmosphere"
            Tags { "LightMode" = "Forward" }

            Blend One One
            ZTest LEqual
            ZWrite Off
            Cull Back

            HLSLPROGRAM

            // 透明
            #define _SURFACE_TYPE_TRANSPARENT 
            // 开启雾
            #define _ENABLE_FOG_ON_TRANSPARENT

            
            // 顶点需要的参数
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            // 片元需要的参数
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_POSITION_WS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            // 纹理
            TEXTURE2D(_AtmosphereTex);

            // SRP
CBUFFER_START(UnityPerMaterial)
            float4 _AtmosphereTex_ST;
		    float _ScatteringOffset, _ScatteringIntensity, _ScatteringFactor;
		    float4 _ScatteringColor, _GlowColor;
            float _GlowOffset, _GlowIntensity, _GlowFactor;

            float _VertexOffset, _UVOffset;
            float _LightPow, _LightSensitivity, _LightAtten;

            float _BlendMode;
CBUFFER_END

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"
             #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.cs.hlsl"

            // 顶点变换
            #define HAVE_MESH_MODIFICATION
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
            {
                input.positionOS += _VertexOffset * input.normalOS;// * 0.1;
                return input;
            }

            
            // 片元
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                float3 normalWS = fragInputs.tangentToWorld[2]; // 世界法线
                float3 view = normalize(GetCameraRelativePositionWS(_WorldSpaceCameraPos) - fragInputs.positionRWS); // 由摄像机世界空间位置与顶点世界位置确定视角方向
			    float NdotV = dot( normalWS , view ); // 世界方向与法线的点积

                // 计算散射
			    float Abs_NdotV = abs( NdotV );
			    float ScatterOffset = saturate( ( ( ( _ScatteringOffset / 10 ) + Abs_NdotV ) * 1000 ) );
			    float4 scatter = ( ScatterOffset * pow( ( 1.0 - saturate( NdotV ) ) , _ScatteringFactor ) * _ScatteringIntensity * ( SAMPLE_TEXTURE2D( _AtmosphereTex, s_linear_clamp_sampler,  _UVOffset + (saturate( NdotV )).xx  ) * _ScatteringColor ) );

                // 计算发光
			    float GlowOffset = saturate( ( ( Abs_NdotV + ( _GlowOffset / 10 ) ) * 1000 ) );
			    float4 glow = ( GlowOffset * saturate( ( pow( ( 1.0 - saturate( NdotV ) ) , _GlowFactor ) * _GlowColor * _GlowIntensity ) ) );

                float4 result;
                if (_DirectionalLightCount <= 0)
                {// 无平行光
                    result = float4(0,0,0,1);
                }
                else
                {// 存在平行光，但只取第一个平行光
                    DirectionalLightData light = _DirectionalLightDatas[0];
                    float3 lightColor = light.color * GetCurrentExposureMultiplier(); // 光源颜色 * 曝光度
			        float3 L = normalize(light.forward); // 光源方向
			        float LdotN = dot( -L, normalWS ); // 光源负方向与法线点积，用于计算当前顶点受光基础程度
			        float LdotV = dot( L , view ); // 光源方向与视角方向点积，用于计算视觉对光源的敏感度
                    // 平行光相对视线衰减
                    float attenFlag = step(1, _LightAtten);
                    float atten =  attenFlag * (1-saturate(LdotV)) + (1-attenFlag);
                    // 组合最后颜色
                    result = float4(0,0,0,0);
			        result.rgb = ( (scatter + glow ) * saturate( pow( saturate( ( LdotN + ( max( LdotV , -0.22 ) * _LightSensitivity ) ) ) , _LightPow ) ) * lightColor * atten ).rgb;
                    //result.rgb = view;
			        result.a = 1;
                }

                // 回传数据
                float opacity = result.a;
                float3 color = result.rgb;
                ZERO_BUILTIN_INITIALIZE(builtinData); 
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = opacity;
                builtinData.emissiveColor = float3(0, 0, 0);
                surfaceData.color = color;
            }


            // 渲染（采用无光着色器，但在组织表面和Builtin数据时，直接使用全局光源的第一盏平行光进行渲染。）
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl" 
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback Off
    CustomEditor "com.graphi.renderhdrp.editor.GeneralEditorShaderGUI"
}