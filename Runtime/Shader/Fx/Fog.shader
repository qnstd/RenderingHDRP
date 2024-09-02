/*
    雾效

    渲染管道：
        High-Definition Render Pipeline

    作者：
        强辰
*/
Shader "Graphi/Fx/Fog"
{
    Properties
    {
        [Space(10)]
        [HDR]_Color("主纹理颜色", Color) = (1,1,1,1)
        _MainTex("主纹理", 2D) = "white" {}
        _MainIntensity("主纹理强度", float) = 1

        // 灰度
        [Space(10)]
        [Foldout]_Desatu("灰度（Gray）", Range(0, 1)) = 0
        [Space(5)]
        [To(_Desatu)]_Desaturate("插值", Range(0,1)) = 0
        [To(_Desatu)]_DesaturatePower("强度", float) = 1

        // 扰动
        [Space(10)]
        [Foldout]_Disturbance("扰动（Disturbance）", Range(0,1)) = 0
        [Space(5)]
        [To(_Disturbance)][MaterialToggle] _DisturSwitch("开启", Float) = 0
        [To(_Disturbance)]_DisturTex("纹理", 2D) = "white" {}
        [To(_Disturbance)]_DisturIntensity("强度", Float) = 0.1
        [To(_Disturbance)]_DisturUSpeed("U 流动速度", Float) = 0
        [To(_Disturbance)]_DisturVSpeed("V 流动速度", Float) = 0

        // 距离比颜色强度
        [Space(10)]
        [Foldout]_Dist("距离（Distance）", Range(0, 1)) = 0
        [Space(5)]
        [To(_Dist)][MaterialToggle] _DistanceSwitch("开启", Float) = 0
        [To(_Dist)]_Near("自定义裁剪面  [近]（非摄像机近裁面）", Float) = 0
        [To(_Dist)]_Far("自定义裁剪面  [远]（非摄像机远裁面） ", Float) = 0

        // 径向遮罩
        [Space(10)]
        [Foldout] _Radial("径向遮罩（Radial Mask）", Range(0,1)) = 0
        [To(_Radial)][MaterialToggle] _RadialSwitch("开启", Float) = 0
        [To(_Radial)]_RadialIntensity("强度", Float) = 0

        // 高级
        [Space(10)]
        [Foldout] _Advanced("高级（Advanced）", Range(0,1)) = 0
        [Space(5)]
        [To(_Advanced)]_DepthVal("交叉软化", float) = 0
        [To(_Advanced)]_Fade("梯度渐变", float) = 1
        [To(_Advanced)][HideInInspector]_BlendMode("_BlendMode", Range(0.0, 1.0)) = 0.5
    }

//Include
    HLSLINCLUDE
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    ENDHLSL

    SubShader
    {
        Tags
        { 
            "RenderPipeline" = "HDRenderPipeline"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
        }
        Pass
        {
            Name "Graphi-Fog"
            Tags { "LightMode" = "Forward" }

            Blend One One
            //Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Off

            HLSLPROGRAM

            //开启半透明
            #define _SURFACE_TYPE_TRANSPARENT 
            //开启场景雾对其影响
            //#define _ENABLE_FOG_ON_TRANSPARENT 
            
            // 顶点需要的参数
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_COLOR

            // 在片元处理是需要透传的参数
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            // 需要正反面判定
            #define VARYINGS_NEED_CULLFACE 

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            

// 纹理
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_DisturTex);
SAMPLER(sampler_DisturTex);
            
// SRP
CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _MainTex_ST, _DisturTex_ST;
            float _Desaturate, _DesaturatePower, _MainIntensity, _DepthVal, _Fade;
            float _DisturSwitch, _DisturIntensity, _DisturUSpeed, _DisturVSpeed;
            float _DistanceSwitch, _Near, _Far;
            float _RadialSwitch, _RadialIntensity;

            float _BlendMode;
CBUFFER_END

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"

            // 顶点变换处理
             #define HAVE_MESH_MODIFICATION
             AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
             {
                 return input;
             }
            
            // 片源操作处理
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
                // 参数准备
                float4 vertexColor = fragInputs.color; //顶点颜色
                float3 normalWS = fragInputs.tangentToWorld[2]; //世界法线（归一化）
                normalWS *= ((fragInputs.isFrontFace) ? 1 : -1);
                float3 view = normalize(GetCameraRelativePositionWS(_WorldSpaceCameraPos) - fragInputs.positionRWS); // 视角方向
                float VdotN = dot(view, normalWS); //视角与法线的点积
                float sceneZ = max(0, LinearEyeDepth(LoadCameraDepth(fragInputs.positionSS.xy), _ZBufferParams) - _ProjectionParams.g);//当前像素裁剪空间计算后的视空间深度值。_ProjectionParams.g: 近裁面值。
                float partZ = max(0, fragInputs.positionSS.w - _ProjectionParams.g); //视空间下对象深度值
              
////////////////////////////////////////////
// 开始计算
                // 根拒扰动纹理对主纹理进行采样
                float2 uv = fragInputs.texCoord0.xy;
                float2 disturuv = uv + _Time.y * float2(_DisturUSpeed, _DisturVSpeed);
                float4 distur = SAMPLE_TEXTURE2D(_DisturTex, sampler_DisturTex, TRANSFORM_TEX(disturuv, _DisturTex));
                float2 sampleuv = lerp(uv, uv + distur.r * _DisturIntensity, _DisturSwitch);
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(sampleuv, _MainTex));

                // 对采样纹理进行去色设置
                float gray = dot(tex.rgb, float3(0.3, 0.59, 0.11)); //灰度值（R * gray.r + G * gray.g + B * gray.b） 
                float3 gray3 = float3(gray, gray, gray);
                float3 desaturate = clamp(pow(lerp(tex.rgb, gray3, _Desaturate), _DesaturatePower), 0, 1); //用 pow 增强去色幅度，非线性。最后将值固定到 [0-1] 区间。
                float3 multi = _Color.rgb * _MainIntensity * vertexColor.rgb * vertexColor.a;
                float var1 = pow(max(0, VdotN), _Fade);  //梯度渐变
                float var2 = saturate((sceneZ - partZ) / _DepthVal); //交叉软化 
                float3 c = var1 * var2 * desaturate * multi;

                // 按照距离比设置显示强度
                float distscale = saturate((length(fragInputs.positionRWS) - _Near) / (_Far - _Near)); //计算顶点在视空间下的距离比（到近裁面距离 / (远裁面-近裁面))
                float factor = lerp(1.0, distscale, _DistanceSwitch);
                c *= factor;

                // 径向遮罩
                c = lerp(c, (c * saturate(pow((1.0 - distance(uv, float2(0.5, 0.5))), exp2(_RadialIntensity)))), _RadialSwitch);
// END
////////////////////////////////////////////

                // 回传数据
                ZERO_BUILTIN_INITIALIZE(builtinData); //无光初始化
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = 1;
                builtinData.emissiveColor = c.rgb;// float3(0, 0, 0);
                surfaceData.color = float3(0,0,0);
            }

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }


Fallback Off
CustomEditor "com.graphi.renderhdrp.editor.FogEditorShaderGUI"
}