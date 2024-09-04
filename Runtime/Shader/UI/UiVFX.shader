/**
    UI VFX 视觉效果

    渲染管线：
        High-Definition Render pipeline
        
    作者：
        强辰
*/
Shader "Graphi/UI/UiVFX"
{
    Properties
    {
        _SplitBar0("", int) = 0 // GUI 分隔条
        
        [HideInInspector][PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [HideInInspector]_Color ("Tint", Color) = (1,1,1,1)

        [Space(10)]
        [Foldout]_StencilM("Stencil",Range(0,1)) = 1
        [Space(8)]
        [To(_StencilM)][IntRange]_Stencil ("Ref", Range(0,255)) = 0
        [To(_StencilM)][Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp ("Compare", Float) = 8
        [To(_StencilM)][Enum(UnityEngine.Rendering.StencilOp)]_StencilOp ("Pass OP", Float) = 0
        [To(_StencilM)][IntRange]_StencilWriteMask ("WriteMask", Range(0,255)) = 255
        [To(_StencilM)][IntRange]_StencilReadMask ("ReadMask", Range(0,255)) = 255
        [Space(8)]
        [Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask ("ColorMask", Float) = 15

        _SplitBar1("", int) = 0 // GUI 分隔条

        // 渐变色
        [Space(10)]
        [Foldout] _Gradients("Gradient", Range(0,1)) = 0
        [Space(8)]
        [To(_Gradients)][Toggle]_GradientFlag("Enable", float) = 0
        [To(_Gradients)]_GradientDir("Dir",Range(0,-360)) = 0
        [To(_Gradients)][HDR]_TopClr("Front Color",Color)=(1,1,1,1)
        [To(_Gradients)][HDR]_BotClr("Back Color",Color)=(1,1,1,1)
        [To(_Gradients)]_GradientBlend("Blend Factor", Range(0,1)) = 0.5

        // 色相
        [Space(10)]
        [Foldout] _Hue("Hue", Range(0,1)) = 0
        [Space(8)]
        [To(_Hue)][Toggle]_HueFlag("Enable", float) = 0
        [To(_Hue)]_Brightness("Brightness", Range(0, 5)) = 1
        [To(_Hue)]_Saturation("Saturation", Range(0, 5)) = 1
        [To(_Hue)]_Contrast("Contrast", Range(0, 5)) = 1

        // 内描边
        [Space(10)]
        [Foldout] _InnerEdge("Inner line", Range(0,1)) = 0
        [Space(8)]
        [To(_InnerEdge)][Toggle]_InnerEdgeFlag("Enable", float) = 0
        [To(_InnerEdge)]_InnerEdgeClr("Color", Color) = (0,0,0,1)
        [To(_InnerEdge)]_InnerEdgeWidth("Width", float) = 1

        // 外描边
        [Space(10)]
        [Foldout] _OutEdge("Out line", Range(0,1)) = 0
        [Space(8)]
        [To(_OutEdge)][Toggle]_OutEdgeFlag("Enable", float) = 1
        [To(_OutEdge)][HDR]_OutEdgeClr("Color", Color) = (0,0,0,1)
        [HideInInspector]_OutEdgeWidth("Width", float) = 1

        // 流光
        [Space(10)]
        [Foldout] _SweepLight("SweepLight", Range(0,1)) = 0
        [Space(8)]
        [To(_SweepLight)][Toggle]_SweepFlag("Enable", float) = 0
        [To(_SweepLight)]_ShowTime("Time", float) = 1.0
        [To(_SweepLight)]_Interval("Interval",  float) = 2.0
        [To(_SweepLight)]_Size("Size", float) = 0.3
        [To(_SweepLight)]_Degree("Degress", float) = 45.0
        [To(_SweepLight)]_BrightnessSweep("Brightness", float) = 1.4
        [To(_SweepLight)][HDR]_SweepClr("Color", Color) = (1,1,1,1)

        // 波动
        [Space(10)]
        [Foldout] _Wave("Wave", Range(0,1)) = 0
        [Space(8)]
        [To(_Wave)][Toggle] _WaveFlag("Enable", float) = 0 
        [To(_Wave)][Enum(X,0,Y,1,XY,2)]_WaveDir("Dir",float) = 2
        [To(_Wave)]_WaveForce("Amp", float) = 5
        [To(_Wave)]_WaveAngle("Angle", float) = 10
        [To(_Wave)]_WaveSpeed("Phase", float) = 5

        // 阴影
        [Space(10)]
        [Foldout] _Shadows("Shadow", Range(0,1)) = 0
        [Space(8)]
        [To(_Shadows)][Toggle]_ShadowFlag("Enable",float) = 1
        [To(_Shadows)]_ShadowClr("Color",Color)=(0,0,0,1)
        [To(_Shadows)]_ShadowAlphaThreshold("Alpha Threshold", Range(0,1)) = 0.5
        [HideInInspector][To(_Shadows)]_ShadowDist("Offset",Vector)=(0,0,0,0)


        // 反色
        [Space(20)]
        [Toggle]_Negation("Negation", float) = 0

        // 灰度
        [Space(5)]
        [Toggle]_Gray("Gray", float) = 0

        _SplitBar2("", int) = 0 // GUI 分隔条
        [Space(10)]
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }


        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Graphi UiVFX"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            // include
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #include "../HLSL/Graphi_Transformation.hlsl"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP


            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex           : SV_POSITION;
                float4 color            : COLOR;
                float2 texcoord         : TEXCOORD0;
                float4 worldPosition    : TEXCOORD1;
                float4 mask             : TEXCOORD2;
                float2 uvOriginXY : TEXCOORD3;
                float2 uvOriginZW : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };


            // 属性
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;
            int _UIVertexColorAlwaysGammaSpace;
            float4 _TextureSampleAdd;
            float4 _ClipRect;
            
            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float4 _MainTex_TexelSize;
                float4 _Color;

                // 着色属性
                float _Negation;
                float _Gray;
                float _HueFlag, _Brightness, _Saturation, _Contrast;
                float _GradientFlag, _GradientDir, _GradientBlend;
                float4 _TopClr, _BotClr;
                float4 _InnerEdgeClr;
                float _InnerEdgeFlag, _InnerEdgeWidth;
                float4 _OutEdgeClr;
                float _OutEdgeFlag, _OutEdgeWidth;
                float _ShowTime, _Interval, _Size, _Degree, _BrightnessSweep , _SweepFlag;
                float4 _SweepClr;
                float _WaveFlag,_WaveSpeed,_WaveAngle,_WaveForce, _WaveDir;
                float4 _ShadowClr, _ShadowDist;
                float _ShadowFlag, _ShadowAlphaThreshold;
            CBUFFER_END
            // 结束


            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.uvOriginXY = TRANSFORM_TEX(v.texcoord1.xy, _MainTex);
                OUT.uvOriginZW = TRANSFORM_TEX(v.texcoord2.xy, _MainTex);
                OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * float2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                if (_UIVertexColorAlwaysGammaSpace)
                {
                    if(!IsGammaSpace())
                    {
                        v.color.rgb = UIGammaToLinear(v.color.rgb);
                    }
                }

                OUT.color = v.color * _Color;
                return OUT;
            }


//判断是否在矩形范围内(原始UV范围内)
inline float IsInRect(float2 pPos, float2 pClipRectXY, float2 pClipRectZW)
{
    pPos = step(pClipRectXY, pPos) * step(pPos, pClipRectZW);
    return pPos.x * pPos.y;
}
//对当前像素周边进行采样
inline float SampleAlpha(int pIndex, v2f i)
{
    const float sinArray[12] = { 0, 0.5, 0.866, 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5 };
    const float cosArray[12] = { 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5, 0, 0.5, 0.866 };
    float2 pos = i.texcoord + _MainTex_TexelSize.xy * float2(cosArray[pIndex], sinArray[pIndex]) * _OutEdgeWidth;
    return IsInRect(pos, i.uvOriginXY, i.uvOriginZW) * (tex2D(_MainTex, pos) + _TextureSampleAdd).a * _OutEdgeClr.a;
}


// ////////////////////////////////////////////////////////////////
// 特殊效果

// 外描边
float4 OutEdge(float4 c, v2f IN)
{
    UNITY_BRANCH
    if(_OutEdgeWidth>0)
    {
        float4 val = float4(_OutEdgeClr.rgb, 0);
        //采样
        for(int i=1; i<12; i++)
        {
            val.w += SampleAlpha(i, IN);
        }
        val.w = clamp(val.w, 0, 1);
        c = (val * (1.0 - c.a)) + (c * c.a);
    }
    return c;
}


// 内描边
float4 Edge(float2 uv, float4 c)
{
    float2 offsetuv = float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * _InnerEdgeWidth;
    float left = tex2D(_MainTex, uv + float2(offsetuv.x, 0)).a;
    float right = tex2D(_MainTex, uv - float2(offsetuv.x, 0)).a;
    float top = tex2D(_MainTex, uv + float2(0, offsetuv.y)).a;
    float bottom = tex2D(_MainTex, uv - float2(0, offsetuv.y)).a;
    float factor = left * right * top * bottom;
    c.rgb = lerp(_InnerEdgeClr.rgb, c.rgb, factor);
    return c;
}


// 流光（扫光灯）
void SweepLight(float2 uv, inout float4 c)
{
    // 计算x轴随时间的偏移量，并矫正x轴偏移量（扫光应从被扫光对象的外部进来。那么当开始进行扫光，x轴时间偏移量0时，实际值应为-1）
    float currentTimePassed = fmod(_Time.y, _ShowTime + _Interval); 
    float xoffset = currentTimePassed / _ShowTime; 
    xoffset += (xoffset - 1);

    //扫光横向区域的左上角x轴位置 及 右上角x轴位置
    float x1 = uv.y / tan(0.0174 * _Degree) + xoffset; 
    float x2 = x1 + _Size; 

    UNITY_BRANCH
    if (uv.x > x1 && uv.x < x2)
    {//当前像素的x轴在扫光区域内
                
        float center = (x1 + x2) * 0.5; //由x1和x2组成的横向区域中心位置
        float dis = abs(uv.x - center); //当前UV与中心位置的差值来确定亮度（当像素x轴在区域的中心位置最亮，向区域边缘减弱）
        float intensity = 1 - dis * 2 / _Size; // 计算强度
        float ca = c.a;
        c += c * _SweepClr * (_BrightnessSweep * intensity);
        c.a = ca;
    }
}

// 渐变
float4 Gradient(float2 uv, float4 c)
{
    float2 tileuv = float2(uv.x / _MainTex_ST.x, uv.y / _MainTex_ST.y);
    UVRot(_GradientDir, float2(0.5,0.5), tileuv);
    float4 gradient = lerp(_BotClr, _TopClr, tileuv.y);
    gradient = lerp(c, gradient, _GradientBlend);
    c.rgb = gradient.rgb * c.a;
    c.a *= gradient.a;
    return c;
}

// 色相
float4 Hue(float4 c)
{
    float3 cc = c.rgb;
    cc *= _Brightness; // 明亮度
    float lum = Luminance(cc);// 饱和度 //取出亮度值
    cc = lerp(lum.xxx, cc, _Saturation);
    float3 avg = float3(0.5, 0.5, 0.5);
    cc = lerp(avg, cc, _Contrast); // 对比度
    c.rgb = cc;
    return c;
}


// 波浪
void Wave(inout float2 uv)
{
    // 公式:  A * Sin(wx + bt) + K （此处忽略 k = 垂直相位）
    float cycleFrequency = _WaveAngle * sqrt(dot(uv,uv)); // 周期频率（sprt操作可直接用 uv.x 代替。此处只是为了参数在微调时可改变效果，不用调整很大数值才出效果）
    float initialPhase = (_WaveSpeed * _Time.y) % 360.0; // 初相位（0-359）
	float anglespeed = sin(cycleFrequency + initialPhase); // 角速度
    float swing = _WaveForce / 1000.0; // 振幅
    float result = swing * anglespeed;

    // 累加
    if(_WaveDir == 0){ uv.x += result; }
    else if(_WaveDir == 1){ uv.y += result; }
    else if(_WaveDir == 2){ uv += result.xx; }
}

// 阴影
void Shadow(inout float4 c, v2f IN)
{
    UNITY_BRANCH
    if(_ShadowDist.x != 0 || _ShadowDist.y != 0)
    {
        float2 uv = float2(IN.texcoord.x - _ShadowDist.x, IN.texcoord.y - _ShadowDist.y);
        float4 shadow = IN.color * (tex2D(_MainTex, uv) + _TextureSampleAdd);
        shadow.rgb = _ShadowClr.rgb;
        shadow.a = max(0, (shadow.a-c.a)) * _ShadowClr.a;
        shadow.a *= IsInRect(uv, IN.uvOriginXY, IN.uvOriginZW); // 需要判断是否在范围内，否则会有穿帮
        float factor = step(_ShadowAlphaThreshold, shadow.a);
        c = lerp(c, shadow, factor);
    }
}

// 结束
// ////////////////////////////////////////////////////////////////

            float4 frag(v2f IN) : SV_Target
            {
                const float alphaPrecision = float(0xff);
                const float invAlphaPrecision = float(1.0/alphaPrecision);
                IN.color.a = round(IN.color.a * alphaPrecision)*invAlphaPrecision;

// ////////////////////////////////////////////////////////////////
// 特殊效果
                // 波动
                if(_WaveFlag == 1)
                    Wave(IN.texcoord);

                // 采样纹理
                float4 c = IN.color * (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);
                // 当前uv是否在原始UV范围内
                c.a *= IsInRect(IN.texcoord, IN.uvOriginXY, IN.uvOriginZW);

                // 渐变色
                c = (_GradientFlag == 1) ? Gradient(IN.texcoord.xy, c) : c;
                // 色相
                c = (_HueFlag == 1) ? Hue(c) : c;
                // 取反
                c.rgb = (_Negation == 1) ? 1 - c.rgb : c.rgb;
                // 置灰
                c.rgb = (_Gray == 1) ? dot(c.rgb, float3(0.299, 0.587, 0.114)) : c.rgb;
                // 流光灯
                if(_SweepFlag == 1)
                    SweepLight(IN.texcoord, c);

                // 内描边
                c = (_InnerEdgeFlag == 1) ? Edge(IN.texcoord.xy, c) : c;
                // 外描边
                c = (_OutEdgeFlag == 1) ? OutEdge(c, IN) : c;

                // 阴影
                if(_ShadowFlag == 1)
                    Shadow(c, IN);

// 结束
// ////////////////////////////////////////////////////////////////
                

                // rect 裁剪
                #ifdef UNITY_UI_CLIP_RECT
                float2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                c.a *= m.x * m.y;
                #endif

                // alpha 裁剪
                #ifdef UNITY_UI_ALPHACLIP
                clip (c.a - 0.001);
                #endif

                c.rgb *= c.a;
                return c;
            }
            ENDCG
        }
    }

    Fallback "Hidden/Graphi/FallbackErr"
    CustomEditor "com.graphi.renderhdrp.editor.UiVFXEditorShaderGUI"
}