/*
    特效通用渲染着色器

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰

    说明：
        1. Shader 中使用了条件判断进行分支操作；
            ① BRANCH    : 非展平模式，与CPU模式相同，如果遇到分支则先判断再进行分支块计算，会打乱执行顺序；
            ② FLATTEN   : 将分支展平，所有分支计算并得到结果后，再进行条件判定选取实际操作结果值；

            *** 由于分支内操作内容的汇编指令数都大于6条，所以采用 BRANCH 标记分支。

        2. 粒子系统自定义数据说明

            customData1
               【暂时未使用】

            customData2
                x   : 负责自定义溶解系数
                y   : 负责自定义扭曲强度

            *** customData1、customData2 在粒子系统中向着色器提供自定义数据。这两个数据必须存在，且顺序不能错。
            *** customData1 的标记必须是 TEXCOORD0，customData2 的标记必须是 TEXCOORD1，且 customData1 和 customData2 的数据类型必须是 xyzw。
            *** 数据类型 xyzw 是为了兼容 DOTs ECS 下使用 CustomPassDrawRenderer 框架渲染。底层数据类型是float2， 使用的是 xy，zw被忽略。若粒子系统的自定义数据只使用 xy 类型，那么 TEXCOORD 寄存器不是以整体进行分割，而是插入式。这会影响底层获取数据的准确性。
*/
Shader "Graphi/Fx/ParticleStandard"
{
    Properties
    {
        //基本项
        [Space(5)]
        [Foldout] _Options("Options", Range(0,1)) = 1
        [To(_Options)][Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc("Blend Src", int) = 5
        [To(_Options)][Enum(UnityEngine.Rendering.BlendMode)] _BlendDst("Blend Dst", int) = 10
        [To(_Options)][Enum(Off,0,On,1)] _ZWrite("Zwrite", float) = 0
        [To(_Options)][Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Ztest", float) = 4
        [To(_Options)][Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", float) = 2
        [To(_Options)][Enum(UnityEngine.Rendering.ColorWriteMask)] _ColorMask("Color Mask", float) = 15

        //模板
        [Space(5)]
        [Foldout] _Stencil("Stencil", Range(0,1)) = 0
        [To(_Stencil)][IntRange] _Ref("Ref", Range(0,255)) = 0
        [To(_Stencil)][Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Compare", float) = 8
        [To(_Stencil)][Enum(UnityEngine.Rendering.StencilOp)] _StencilPass("Pass OP", float) = 0
        [To(_Stencil)][Enum(UnityEngine.Rendering.StencilOp)] _StencilFail("Fail OP", float) = 0
        [To(_Stencil)][Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail("ZFail OP", float) = 0
        [To(_Stencil)][IntRange] _StencilReadMask("Read Mask", Range(0,255)) = 255
        [To(_Stencil)][IntRange] _StencilWriteMask("Write Mask", Range(0,255)) = 255

        //主纹理属性
        [Space(5)]
        [Foldout] _BaseFunc("Base", Range(0,1)) = 1
        [To(_BaseFunc)][HDR]_Tint("Color", Color) = (1,1,1,1)
        [To(_BaseFunc)]/*[SingleLine]*/_MainTex("Tex", 2D) = "white"{}
        [To(_BaseFunc)]_MainRot("Rotation", Range(0,360)) = 0
        [To(_BaseFunc)]_MainIntensity("Force",float) = 1
        [To(_BaseFunc)][Enum(Off,0,On,1)]_LumFlag("Luminance",float)=0
        [To(_BaseFunc)]_LumMulti("Lum multi",Range(0,10)) = 0
        [To(_BaseFunc)]_LuminancePow("lum pow", Range(0.001, 6)) = 0.001
        [To(_BaseFunc)]_MainTex_U("U speed", float) = 0
        [To(_BaseFunc)]_MainTex_V("V speed", float) = 0

        //遮罩属性
        [Space(5)]
        [Foldout] _MaskFunc("Mask", Range(0,1)) = 0
        [To(_MaskFunc)]_MaskTex("Tex", 2D) = "white"{}
        [To(_MaskFunc)]_MaskRot("Rotation", Range(0,360)) = 0
        [To(_MaskFunc)]_MaskIntensity("Force", float) = 1
        [To(_MaskFunc)]_MaskTex_U("U speed", float) = 0
        [To(_MaskFunc)]_MaskTex_V("V speed", float) = 0

        //溶解属性
        [Space(5)]
        [Foldout] _DissFunc("Dissolve", Range(0,1)) = 0
        [To(_DissFunc)]_DissolveTex("Tex", 2D) = "white"{}
        [To(_DissFunc)]_DissolveTex_U("U speed", float) = 0
        [To(_DissFunc)]_DissolveTex_V("V speed", float) = 0
        [To(_DissFunc)][HDR]_DissolveColor("Color", Color) = (1,1,1,1)
        [To(_DissFunc)][Enum(Custom,0,Mat,1)]_DissolveIntensityType("Data Source", float) = 1
        [To(_DissFunc)]_DissolveIntensity("Force", Range(0,1)) = 0
        [To(_DissFunc)]_DissolveEdgeIntensity("Edge Force", Range(0,1)) = 0.5
        [To(_DissFunc)]_DissArea("Edge Area", float) = 0.1

        //扭曲属性
        [Space(5)]
        [Foldout] _TwistFunc("Twist", Range(0,1)) = 0
        [To(_TwistFunc)]_TwistTex("Tex", 2D) = "white"{}
        [To(_TwistFunc)]_TwistMskTex("Tex Mask", 2D) = "white"{}
        [To(_TwistFunc)]_UVFloatParams("UV speed", Vector) = (0,0,0,0)
        [To(_TwistFunc)][Enum(Custom,0,Mat,1)]_TwistIntensityType("Data Source", float) = 1
        [To(_TwistFunc)]_TwistIntensity("Force", float) = 0
        [To(_TwistFunc)][Enum(Off,0,On,1)]_TwistMainTex("Twist Albedo", float) = 1
        [To(_TwistFunc)][Enum(Off,0,On,1)]_TwistDissolveTex("Twist Dissolve", float) = 1
        [To(_TwistFunc)][Enum(Off,0,On,1)]_TwistMaskTex("Twist Mask", float) = 0

        //顶点动画属性
        [Space(5)]
        [Foldout] _VertexAniFunc("Vertex Animation", Range(0,1)) = 0
        [To(_VertexAniFunc)]_VertexAniTex("Tex", 2D) = "white"{}
        [To(_VertexAniFunc)]_VertexAni_U("U offset", float) = 0
        [To(_VertexAniFunc)]_VertexAni_V("V offset", float) = 0
        [To(_VertexAniFunc)]_VertexAniForce("Force", float) = 0

        //菲涅尔
        [Space(5)]
        [Foldout] _FresnelFunc("Fresnel", Range(0,1)) = 0
        [To(_FresnelFunc)][Enum(Gradient,0,General,1)]_FresnelType("Type", float) = 0
        [To(_FresnelFunc)][HDR]_FresnelColor("Color", Color) = (1,1,1,1)
        [To(_FresnelFunc)]_FresnelArea("Area", float) = 1
        [To(_FresnelFunc)]_FresnelIntensity("Force", float) = 0

        //Hue
        [Space(5)]
        [Foldout] _HueFunc("Hue", Range(0,1)) = 0
        [To(_HueFunc)]_Brightness("Brightness", Range(0,3)) = 1
        [To(_HueFunc)]_Saturation("Saturate", Range(0,3)) = 1
        [To(_HueFunc)]_Contrast("Contrast", Range(0,3)) = 1

        //高级设置
        [Space(10)]
        [Foldout]_Advanced("Advanced", Range(0,1)) = 0
        [Space(5)]
        [To(_Advanced)][Toggle]_USEVOLUMEFOG("Fog",float) = 0
        [To(_Advanced)][Enum(UnityEditor.Rendering.HighDefinition.BlendMode)]_BlendMode("Fog blend mode", float) = 0
        [Space(5)]
        [To(_Advanced)][FloatRange]_Soft("Fade", Range(0.01, 10)) = 0.01
        [To(_Advanced)][FloatRange]_AlphaCulloff("Alpha Culloff", Range(0, 1)) = 0
    }
    

//HLSL Include
HLSLINCLUDE
#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

// 内置变体
// #pragma enable_d3d11_debug_symbols
#pragma multi_compile_instancing // 开启 GPU Instancing 实例支持
#pragma multi_compile _ DOTS_INSTANCING_ON // DOTS ECS 支持

// 自定义变体
#pragma shader_feature_local _USEVOLUMEFOG_OFF _USEVOLUMEFOG_ON
ENDHLSL


SubShader
    {
        Tags
        {
            "RenderPipeline" = "HDRenderPipeline"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "PreviewType" = "Shape"
        }

        Pass
        {
            Name "Graphi-ParticleStandard"
            Tags { "LightMode" = "Forward" }

            //设置基础设置
            Blend [_BlendSrc] [_BlendDst]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull [_CullMode]

            //颜色通道裁剪
            ColorMask [_ColorMask]
           
            //模板测试
            Stencil
            {
                Ref[_Ref]
                Comp[_StencilComp]
                Pass[_StencilPass]
                Fail[_StencilFail]
                ZFail[_StencilZFail]
                ReadMask[_StencilReadMask]
                WriteMask[_StencilWriteMask]
            }


            HLSLPROGRAM
   
            // 开启其他效果渲染功能
            #define _SURFACE_TYPE_TRANSPARENT //开启表面透明
            #define _ALPHATEST_ON //Alpha裁剪
#ifdef _USEVOLUMEFOG_ON
            #define _ENABLE_FOG_ON_TRANSPARENT //透明物体支持体积雾影响
#endif

            // 顶点需要的变量
            #define ATTRIBUTES_NEED_NORMAL //法线
            #define ATTRIBUTES_NEED_TANGENT //切线
            #define ATTRIBUTES_NEED_COLOR //顶点颜色
            #define ATTRIBUTES_NEED_TEXCOORD0 //UV0 对应 CustomData1
            #define ATTRIBUTES_NEED_TEXCOORD1 //UV1 对应 CustomData2
            #define ATTRIBUTES_NEED_TEXCOORD2 //UV2 对应 UV

            // 片段需要的变量
            #define VARYINGS_NEED_POSITION_WS //相对摄像机空间下的世界坐标
            #define VARYINGS_NEED_TANGENT_TO_WORLD //包含世界法线，世界切线
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_TEXCOORD0 
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

// 变体 （采用 shader_feature 变体标记是为了优化在构件时的着色器变体数量）
#pragma shader_feature __ _FresnelIntensity_On
#pragma shader_feature __ _MaskTex_On
#pragma shader_feature __ _DissolveTex_On
#pragma shader_feature __ _TwistTex_On
#pragma shader_feature __ _VertexAniTex_On
#pragma shader_feature __ _Hue_On
#pragma shader_feature __ _Soft_On
// END


 //纹理
TEXTURE2D(_MainTex); //主纹理
SAMPLER(sampler_MainTex);
TEXTURE2D(_MaskTex); //遮罩纹理
SAMPLER(sampler_MaskTex);
TEXTURE2D(_DissolveTex); //溶解纹理
SAMPLER(sampler_DissolveTex);
TEXTURE2D(_TwistTex); //扭曲纹理
SAMPLER(sampler_TwistTex);
TEXTURE2D(_TwistMskTex); //扭曲纹理的遮罩纹理
SAMPLER(sampler_TwistMskTex);
TEXTURE2D(_VertexAniTex); //顶点动画纹理
SAMPLER(sampler_VertexAniTex);


//SRP
CBUFFER_START(UnityPerMaterial)
//主图参数
float4 _MainTex_ST;
float4 _Tint;
float _MainTex_U, _MainTex_V;
float _LuminancePow, _LumMulti, _LumFlag;
float _MainRot;
float _MainIntensity;
//软粒子参数
float _Soft;
//Hue参数
float _Brightness;
float _Saturation;
float _Contrast;
//菲涅尔参数
float _FresnelType;
float4 _FresnelColor;
float _FresnelArea;
float _FresnelIntensity;
//遮罩参数
float4 _MaskTex_ST;
float _MaskTex_U, _MaskTex_V;
float _MaskIntensity;
float _MaskRot;
//溶解参数
float4 _DissolveColor;
float4 _DissolveTex_ST;
float _DissolveTex_U, _DissolveTex_V, _DissolveEdgeIntensity, _DissolveIntensity, _DissArea, _DissolveIntensityType;
//扭曲参数
float4 _TwistTex_ST, _TwistMskTex_ST, _UVFloatParams;
float _TwistIntensityType, _TwistIntensity;
float _TwistMainTex, _TwistDissolveTex, _TwistMaskTex;
//顶点动画参数
float4 _VertexAniTex_ST;
float _VertexAni_U, _VertexAni_V;
float _VertexAniForce;
//高级项
float _BlendMode; //雾混合
float _AlphaCulloff; //Alpha裁剪
CBUFFER_END


#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"
#include "../HLSL/Graphi_Transformation.hlsl"
#include "../HLSL/Graphi_Color.hlsl"

////////////////////////////////////////////////////////////////////////////////////////
/// 操作函数

// 针对内置 SmoothStep 函数做优化，去掉平滑插值
float Smoothstep_Simple(float val, float min, float max)
{
    val = (val - min) / (max - min);
    val = saturate(val);
    return val;
}

// 顶点动画
float3 VertexAni(float2 uv, float3 normalOS)
{
    float2 vertexAni_sampleuv = uv + float2(_VertexAni_U, _VertexAni_V) * _Time.y;
    float vani = SAMPLE_TEXTURE2D_X_LOD(_VertexAniTex, sampler_VertexAniTex, vertexAni_sampleuv, 0).r;
    vani *= _VertexAniForce;
    return normalOS * vani;
}

// 扭曲处理
void Twist(FragInputs fragInputs, float2 uvTwist, float2 uvTwistMsk, 
    inout float2 uvMain, inout float2 uvMask, inout float2 uvDissolve)
{
    //选取扭曲强度的数据来源
    float val = step(1, _TwistIntensityType);
    float force = val * _TwistIntensity + (1 - val) * fragInputs.texCoord1.y;

    //采样扭曲遮罩纹理
    float2 twistMaskUV = uvTwistMsk + _UVFloatParams.zw * _Time.y;
    float twistMask = SAMPLE_TEXTURE2D(_TwistMskTex, sampler_TwistMskTex, twistMaskUV).r;

    //采样扭曲纹理
    float2 twistUV = uvTwist + _UVFloatParams.xy * _Time.y;
    float4 twist = SAMPLE_TEXTURE2D(_TwistTex, sampler_TwistTex, twistUV);
    twist *= twistMask;

    //计算扭曲值
    twist = (twist * 2 - 1) * force; //扭曲范围 [-1,1] * force
    float2 offset = twist.xy;

    //应用扭曲
    uvMain += step(1, _TwistMainTex) * offset; //主纹理
    uvMask += step(1, _TwistMaskTex) * offset; //遮罩纹理
    uvDissolve += step(1, _TwistDissolveTex) * offset; //溶解纹理
}

// 主纹理操作
float4 MainTex_Operate(FragInputs fragInputs, float2 uvMain)
{
    float2 _uv = uvMain;
    float2 pivot = float2(0.5, 0.5); //旋转中心点
    pivot *= _MainTex_ST.xy;
    pivot += _MainTex_ST.zw;
    UVRot(_MainRot, pivot, _uv);
    //偏移
    float2 uvoffset = float2(_MainTex_U, _MainTex_V) * _Time.y;
    _uv += uvoffset;

    float4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _uv) * _Tint * fragInputs.color * _MainIntensity;
    UNITY_BRANCH
        if (_LumFlag != 0)
        {//提取主贴图中的亮度值，并对其进行指数计算后得到的最终亮度值与源颜色相加。此操作可以增加主贴图的质感。
            float lum = Luminance(c.rgb);
            float lumpow = pow(lum * _LumMulti, _LuminancePow);
            lum += lumpow;
            /*float3 lumc = float3(lum, lum, lum);
            c.rgb = lumc;*/
            c.rgb += c.rgb * lum;
        }
    return c;
}

// 遮罩处理
void Operate_Msk(inout float4 c, float2 muv)
{
    //旋转
    float2 mskuv = muv;
    float2 pivot = float2(0.5, 0.5); //旋转中心点
    pivot *= _MaskTex_ST.xy;
    pivot += _MaskTex_ST.zw;
    UVRot(_MaskRot, pivot, mskuv);

    //偏移
    float2 uvoffset = float2(_MaskTex_U, _MaskTex_V) * _Time.y;
    mskuv += uvoffset;

    //遮罩图采样
    float msk = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, mskuv).r;
    //强度
    msk *= _MaskIntensity;
    //应用
    c *= msk;
}

// 溶解处理
void Dissolve(inout float4 c, float2 uv, FragInputs fragInputs)
{
    //采样溶解纹理
    float2 dissUVOffset = float2(_DissolveTex_U, _DissolveTex_V) * _Time.y;
    float2 dissUV = uv + dissUVOffset;
    float disstex = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, dissUV).r;

    //准备参数
    float area = _DissArea; //溶解边缘宽度
    float hardness = _DissolveEdgeIntensity; //软硬程度
    float factor = lerp(_DissolveIntensity, fragInputs.texCoord1.x, step(_DissolveIntensityType, 0)); ///溶解系数（0：不溶解；1：完全溶解）custom = i.customData2

    //执行溶解
    disstex = clamp(disstex, 0, 0.99999);
    float threshold = disstex - factor;
    clip(threshold);
    /*if (threshold < 0)
    {
        c.a *= saturate(1 - (factor + 0.7));
        return;
    }*/

    float edgeFactor = saturate((disstex - factor) / (area * factor));
    float4 blendColor = _DissolveColor;
    blendColor.a *= pow(saturate(edgeFactor + hardness), 30);

    //混合颜色
    c = lerp(c, blendColor, 1 - edgeFactor);
}

// 菲涅尔效果
void Fresnel(float NdotV, inout float4 c)
{
    float nv = 1 - saturate(NdotV);
    UNITY_BRANCH //这里使用非展平模式
        if (_FresnelType == 0)
        {//由边缘向中心渐变过度
            float4 fresnel = pow(nv, _FresnelArea) * _FresnelIntensity * _FresnelColor;
            fresnel.a *= nv; //修改fresnel颜色的alpha通道值，使颜色渐变过度更平滑一些。
            c += fresnel;
        }
        else if (_FresnelType == 1)
        {//由边缘向中心颜色填充，没有透明渐变过度
            nv = Smoothstep_Simple(nv, 1 - _FresnelArea, 1);
            float4 fresnel = _FresnelColor * nv * _FresnelIntensity;
            c.rgb += fresnel.rgb;
            c.a *= 1 - nv;
        }
}

// 交叉处软化
void Soft(FragInputs fragInputs, inout float4 c)
{
    float sceneZ = LinearEyeDepth(LoadCameraDepth(fragInputs.positionSS.xy), _ZBufferParams);//当前像素裁剪空间计算后的视空间深度值
    float objZ = fragInputs.positionSS.w; //视空间下对象深度值
    float fade = saturate(_Soft * (sceneZ - objZ));
    //c = float4(fade, fade, fade, 1);
    c.a *= fade;
}


/// END
////////////////////////////////////////////////////////////////////////////////////////

// 顶点变换（顶点动画）操作处理函数
             #define HAVE_MESH_MODIFICATION
             AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
             {
                 //修改顶点信息
                 float2 uvAni = TRANSFORM_TEX(input.uv2.xy, _VertexAniTex);
                 float3 normalOS = input.normalOS;
                 float3 posOS_offset = float3(0, 0, 0);
#if _VertexAniTex_On
                 posOS_offset = VertexAni(uvAni, normalOS);
#endif
                 float3 posOS = input.positionOS + posOS_offset;
                 input.positionOS = posOS;

                 return input;
             }

// 片段渲染时，自定义处理操作函数
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                //参数准备
                float2 uv = fragInputs.texCoord2.xy; //主UV（若不在粒子系统，texCoord0-2都是主UV；若在粒子系统情况下，texCoord2是主UV，texCoord0-1是自定义数据）
                float2 uvMain = TRANSFORM_TEX(uv, _MainTex); //主纹理UV
                float2 uvMask = float2(0, 0), uvDissolve = float2(0, 0), uvTwist = float2(0, 0), uvTwistMask = float2(0, 0);
#if _MaskTex_On
                uvMask = TRANSFORM_TEX(uv, _MaskTex); //遮罩UV
#endif
#if _DissolveTex_On
                uvDissolve = TRANSFORM_TEX(uv, _DissolveTex); //溶解UV
#endif
#if _TwistTex_On
                uvTwist = TRANSFORM_TEX(uv, _TwistTex); //扭曲UV
                uvTwistMask = TRANSFORM_TEX(uv, _TwistMskTex); //扭曲遮罩UV
#endif

                float3 viewDir = viewDirection; //世界空间下视角方向（归一化）
                float3 nWS = fragInputs.tangentToWorld[2]; //世界法线（归一化）
                float NdotV = dot(nWS, viewDir); //视角与法线的点积

// 扭曲处理
#if _TwistTex_On
                Twist(fragInputs, uvTwist, uvTwistMask, uvMain, uvMask, uvDissolve);
#endif

// 主纹理处理
                float4 result = MainTex_Operate(fragInputs, uvMain);

// 遮罩处理
#if _MaskTex_On
                Operate_Msk(result, uvMask);
#endif

// 溶解处理
#if _DissolveTex_On
                Dissolve(result, uvDissolve, fragInputs);
#endif

// 菲涅尔边缘光
#if _FresnelIntensity_On
                Fresnel(NdotV, result);
#endif

//Soft Fade 交接处软化（这里不做Toogle开关模式，节省变体。用计算换内存方式执行）
#if _Soft_On
                Soft(fragInputs, result);
#endif

//Hue
#if _Hue_On
                result = Hue(result, _Brightness, _Saturation, _Contrast);
#endif

// Alpha裁剪
#ifdef _ALPHATEST_ON
                DoAlphaTest(result.a, _AlphaCulloff);
#endif
                // 回传数据
                ZERO_BUILTIN_INITIALIZE(builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = result.a;
                builtinData.emissiveColor = float3(0, 0, 0);
                surfaceData.color = result.rgb;
            }

// 执行渲染
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }


    Fallback "Hidden/Graphi/FallbackErr"
    CustomEditor "com.graphi.renderhdrp.editor.ParticleStandardEditorShaderGUI"
}