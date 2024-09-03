/**
    护盾

    渲染管线：
        High-Definition RenderPipeline

    作者：
        强辰
*/
Shader "Graphi/Fx/Shield"
{
    Properties
    {
        [Foldout]_Base("Base", Range(0, 1)) = 1
        [To(_Base)][HDR]_Color("Color", Color) = (1,1,1,1)
        [To(_Base)][SingleLine][NoScaleOffset]_Tex("Tex", CUBE) = "white"{}
        [To(_Base)]_TexPow("Force", float) = 1

        [Space(10)]
        [Foldout]_Rim("Rim", Range(0, 1)) = 1
        [To(_Rim)][HDR]_RimColor("Color", Color) = (1,1,1,1)
        [To(_Rim)]_RimPow("Force", float) = 3

        [Space(10)]
        [Foldout]_Intersect("Fade", Range(0,1)) = 1
        [To(_Intersect)][HDR]_IntersectColor("Color", Color) = (1,1,1,1)
        [To(_Intersect)]_IntersectArea("Area", float) = 1
        [To(_Intersect)]_IntersectPow("Pow", float) = 6

        [Space(10)]
        [Foldout]_Msks("Mask", Range(0,1)) = 1
        [To(_Msks)][HDR]_MskColor("color", Color) = (1,1,1,1)
        [To(_Msks)]_MskTex("tex", 2D) = "white"{}
        [To(_Msks)]_MskFloatSpeed("speed", Vector) = (0,0,0,0)

        [Space(10)]
        [Foldout]_Interaction("Interaction", Range(0, 1)) = 1
        [To(_Interaction)][HDR] _TouchColor("Touch Color", Color) = (1,0,0,1)
        [To(_Interaction)] _TouchColorIntensity("Touch Force", float) = 10
        [To(_Interaction)] _TouchColorRadiasAtten("Touch RadiasAtten", float) = 3

        [HideInInspector]_AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0
        [HideInInspector]_BlendMode("_BlendMode", Range(0.0, 1.0)) = 0.5
    }


// Include
    HLSLINCLUDE

    //#pragma editer_sync_compliation // 编辑环境强制同步编译


    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    // 变体
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON

    ENDHLSL
// 结束


    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline" 
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Graphi Shield"
            Tags { "LightMode" = "Forward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Off

            HLSLPROGRAM

            // 开启Alpha测试
            #define _ALPHATEST_ON
            // 开启透明模式
            #define _SURFACE_TYPE_TRANSPARENT
            // 开启透明体与雾混合
            #define _ENABLE_FOG_ON_TRANSPARENT
            
            // 顶点需要的参数
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_COLOR

            // 片段着色需要的参数
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_CULLFACE

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            
            // 纹理
            TextureCube<float4> _Tex;
            TEXTURE2D(_MskTex);
            SAMPLER(sampler_MskTex);

            /**
               碰撞点处理的最大数 （详细说明请查看同名 c# 脚本文件）
            */
            #define MAX_TOUCHNUM  100


            // 缓冲
CBUFFER_START(UnityPerMaterial)
            float _AlphaCutoff;
            float _BlendMode;

            float4 _Color;
            float _TexPow;
            float4 _RimColor;
            float _RimPow;
            float4 _IntersectColor;
            float _IntersectArea;
            float _IntersectPow;
            float4 _MskTex_ST;
            float4 _MskColor;
            float4 _MskFloatSpeed;

            // 可交互的属性
            float3 _TouchPoints[MAX_TOUCHNUM]; // 撞击点
            float4 _TouchPointDatas[MAX_TOUCHNUM]; // x: 以撞击点为中心的半径，y: 变化总强度，zw: 暂未使用
            float _TouchNumbers; // 当前的撞击点数
            float4 _TouchColor;
            float _TouchColorIntensity, _TouchColorRadiasAtten;
            // 结束
CBUFFER_END

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"

            
            // 顶点变换
            #define HAVE_MESH_MODIFICATION
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
            {
                // 根据撞击点进行操作
                for(int i=0; i<_TouchNumbers; i++)
                {
                    float3 pos = TransformObjectToWorld(input.positionOS);
                    float3 touch = GetCameraRelativePositionWS(_TouchPoints[i]);
                    float dist = distance(pos , touch);
                    float show = 1 - step(_TouchPointDatas[i].x, dist); 
                    input.positionOS.xyz += -input.normalOS * _TouchPointDatas[i].y * (1 - clamp(dist, 0, 1)) * show; 
                }
                 
                return input;
            }


            // 表面渲染
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                    // 准备后续计算需要的参数
                    float3 wnormal = normalize(fragInputs.tangentToWorld[2]); // 世界法线
                    float NdotV = dot(wnormal, normalize(viewDirection)); // 世界法线和朝向的点积
                    float4 result = float4(0,0,0,0); // 最终颜色

                    // 边缘光
                    float OneMinusNdotV = 1 - abs(NdotV);
                    float4 rimcolor = pow(abs(OneMinusNdotV), _RimPow) * _RimColor;
                    result += rimcolor;

                    // 与不透明物体接触时，交界处高亮
                    float sceneZ = LinearEyeDepth( LoadCameraDepth(fragInputs.positionSS.xy), _ZBufferParams ); // 当前像素在视空间下的深度
                    float objZ = fragInputs.positionSS.w; // 当前顶点在视空间下的对象深度
                    float zSplus = sceneZ - objZ; // 深度差
                    if(zSplus < _IntersectArea)
                    {
                        float intersectFactor = 1- (zSplus / _IntersectArea);
                        intersectFactor = saturate(intersectFactor);
                        intersectFactor = pow(intersectFactor, _IntersectPow);
                        result += _IntersectColor * intersectFactor;
                        //result.a *= saturate(zSplus * 15); // 交叉位置更平滑
                    }

                    // 纹理
                    float4 tex = SAMPLE_TEXTURECUBE_LOD(_Tex, s_linear_clamp_sampler, wnormal, 0) * ((NdotV < 0) ? 0 : 1);
                    tex *= pow(abs(OneMinusNdotV), _TexPow);
                    float4 texcolor = tex * _Color;
                    result += texcolor;

                    // 遮罩
                    float2 mskuv = TRANSFORM_TEX(fragInputs.texCoord0.xy, _MskTex);
                    float msk = 
                                SAMPLE_TEXTURE2D(_MskTex, sampler_MskTex, mskuv + _Time.y * _MskFloatSpeed.xy).r +
                                SAMPLE_TEXTURE2D(_MskTex, sampler_MskTex, mskuv - _Time.y * _MskFloatSpeed.zw).r
                                ;
                    msk = saturate(msk);
                    float4 mskcolor = msk * _MskColor * texcolor;
                    result += mskcolor;

                    // ////// 交互效果 ////// 
                    for(int i=0; i<_TouchNumbers; i++)
                    {
                        float3 pos = fragInputs.positionRWS;
                        float3 touch = GetCameraRelativePositionWS(_TouchPoints[i]);
                        float dist = distance(pos , touch); // 像素点与触碰点的距离
                        float show = 1 - step(_TouchPointDatas[i].x, dist);  // 是否处理小于半径的像素

                        // 碰撞颜色 = 颜色 * 碰撞颜色强度 * 径向衰减 * 是否显示碰撞颜色 
                        float4 changeColor = _TouchColor * (_TouchColorIntensity * 10000) * pow( clamp(dist, 0, 1), _TouchColorRadiasAtten) * show;
                        // 撞击力度因子
                        changeColor *= _TouchPointDatas[i].y;
                        // 以基础纹理的alpha进行裁剪
                        changeColor *= texcolor.a;

                        result.rgb += changeColor.rgb;
                    }
                    // ////// 结束 ////// 


                    // 将alpha调整到[0-1]
                    result.a = saturate(result.a);


// //////////////////////////////////////////////////////////////////////

                    float opacity = result.a;
                    float3 color = result.rgb;
#ifdef _ALPHATEST_ON
                    DoAlphaTest(opacity, _AlphaCutoff);
#endif

                    // 回传数据
                    ZERO_BUILTIN_INITIALIZE(builtinData);
                    ZERO_INITIALIZE(SurfaceData, surfaceData);
                    builtinData.opacity = opacity;
                    builtinData.emissiveColor = float3(0, 0, 0);
                    surfaceData.color = color;
            }

            // 着色程序
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    FallBack Off
    CustomEditor "com.graphi.renderhdrp.editor.ShieldEditorShaderGUI"
}