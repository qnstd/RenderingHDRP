/*
    闪电类型着色器

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Graphi/Fx/Lightning"
{
    Properties
    {
        //主纹理
        [Foldout] _Main("Albedo",Range(0,1)) = 1
        [Space(5)]
        [To(_Main)][HDR]_TintColor("Color", Color) = (0.5,0.5,0.5,0.5)
        [To(_Main)]_MainTex("Tex", 2D) = "white" {}
        [To(_Main)]_Offset("Offset", Range(-1,1)) = 0
        //扭曲
        [Space(10)]
        [Foldout]_Twist("Twist",Range(0,1)) = 1
        [Space(5)]
        [To(_Twist)]_TwistTex1("Tex1", 2D) = "white" {}
        [To(_Twist)]_TwistTex2("Tex2", 2D) = "white" {}
        [To(_Twist)]_TwistParams("Sample Params", Vector) = (1,1,0.1,0.1)
        //高级设置
        [Space(10)]
        [Foldout]_Advanced("Advanced", Range(0,1)) = 0
        [Space(5)]
        [To(_Advanced)][Toggle]_USEVOLUMEFOG("Fog",float) = 0
        [To(_Advanced)][Enum(UnityEditor.Rendering.HighDefinition.BlendMode)]_BlendMode("Fog blend", float) = 0
        [Space(5)]
        [To(_Advanced)][FloatRange]_AlphaCulloff("Alpha Cutoff", Range(0, 1)) = 0

    }


//HLSL Include
HLSLINCLUDE
#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

// 开启 GPU 实例支持
#pragma multi_compile_instancing
// 支持 DOTS ECS 模式
#pragma multi_compile _ DOTS_INSTANCING_ON

// 体积雾
#pragma multi_compile _USEVOLUMEFOG_OFF _USEVOLUMEFOG_ON
ENDHLSL


    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline" 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "PreviewType"="Shape"
        }

        //Blend SrcAlpha OneMinusSrcAlpha
        Blend SrcAlpha One
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest LEqual

        Pass
        {
            Name "Graphi-Lightning"
            Tags { "LightMode" = "Forward" }

            HLSLPROGRAM

            #define _SURFACE_TYPE_TRANSPARENT //开启表面半透明 
            #define _ALPHATEST_ON //Alpha 裁剪
#ifdef _USEVOLUMEFOG_ON
            #define _ENABLE_FOG_ON_TRANSPARENT //受雾影响。若开启，shader必须包含_BlendMode参数，未包含情况下在 Material.hlsl 计算雾时会报错。其值在 MaterialBlendModeEnum.cs.hlsl 中定义。
#endif

            // 获取需要网格信息数据的开关（ 详细可以查看 VaryingMesh.hlsl ）
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR

            // 网格信息变种需要获取的数据开关，对应ATTRIBUTES顶点属性
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

//纹理
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_TwistTex1);
SAMPLER(sampler_TwistTex1);
TEXTURE2D(_TwistTex2);
SAMPLER(sampler_TwistTex2);
            
//SRP
CBUFFER_START(UnityPerMaterial)
float4 _TintColor;
float4 _TwistParams;
float _Offset;
float4 _MainTex_ST; 
float4 _TwistTex1_ST;
float4 _TwistTex2_ST;
float _BlendMode;
float _AlphaCulloff;
CBUFFER_END


#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"

             // 顶点变换操作函数            
             #define HAVE_MESH_MODIFICATION
             AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
             {
                 return input;
             }

            // 用于计算回传需要的渲染数据
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                //计算参数准备
                float2 posWS = posInput.positionWS.xy;
                float2 uvTwist1 = TRANSFORM_TEX(posWS, _TwistTex1);
                float2 uvTwist2 = TRANSFORM_TEX(posWS, _TwistTex2);
                float2 uvMain = TRANSFORM_TEX(fragInputs.texCoord0.xy, _MainTex);
                float4 vertexColor = fragInputs.color;

                //对扭曲纹理 1 进行采样
                float vertexColor_R = vertexColor.r;
                float4 t1 = SAMPLE_TEXTURE2D(_TwistTex1, sampler_TwistTex1, uvTwist1 + _TwistParams.x * vertexColor_R / 10) * 2 - 1;
                float4 t2 = SAMPLE_TEXTURE2D(_TwistTex1, sampler_TwistTex1, uvTwist1 - _TwistParams.x * vertexColor_R / 10 * 1.4 + float2(0.4, 0.6)) * 2 - 1;
                //对扭曲纹理 2 进行采样
                float4 t3 = SAMPLE_TEXTURE2D(_TwistTex2, sampler_TwistTex2, uvTwist2 + _TwistParams.y * vertexColor_R / 10) * 2 - 1;
                float4 t4 = SAMPLE_TEXTURE2D(_TwistTex2, sampler_TwistTex2, uvTwist2 - _TwistParams.y * vertexColor_R / 10 * 1.25 + float2(0.3, 0.7)) * 2 - 1;

                /////////////////////////////////////
                // 3次采样是因为采样的坐标不同
                // 
                //采样主纹理取 G 通道做偏移
                float2 _uvmain = uvMain;
                float offset = saturate(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _uvmain).g + _Offset);
                //采样主纹理取 R 通道获取纹理色
                _uvmain = uvMain + (t1.xy + t2.xy) * _TwistParams.z * offset + (t3.xy + t4.xy) * _TwistParams.w * offset;
                float tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _uvmain).r;
                //采样主纹理取 B 通道获取Alpha值
                _uvmain = uvMain * 7 + _Time.x * 5;
                float alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _uvmain).b;
                //
                //END
                //////////////////////////////////////

                //alpha裁剪
                float vertexColor_A = vertexColor.a;
                clip(vertexColor_A - alpha); //顶点颜色的alpha值 - 纹理采样B通道的值 < 0

                //计算最终颜色
                float4 result = 2.0f * _TintColor * tex * vertexColor_A;
                float opacity = result.a; //alpha 
                float3 color = result.rgb; //rgb

                // Alpha裁剪
#ifdef _ALPHATEST_ON
                DoAlphaTest(opacity, _AlphaCulloff);
#endif

                // 将数据写回输出结构体
                ZERO_BUILTIN_INITIALIZE(builtinData); // 不需要光照，所以不需要调用 InitBuildinData
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = opacity;
                builtinData.emissiveColor = float3(0, 0, 0);
                surfaceData.color = color;
            }

//顶点、片元程序
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    Fallback Off
    CustomEditor "com.graphi.renderhdrp.editor.LightningShaderGUI"
}