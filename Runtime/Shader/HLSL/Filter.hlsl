#ifndef GRAPHI_FILTER
#define GRAPHI_FILTER

// include
#include "Color.hlsl"


// 单色比率
#define ColorRatio_Red 0.4
#define ColorRatio_Green 0.4
#define ColorRatio_Yellow 0.6
// 复色比率
#define ColorRatio_Blue 0.2
#define ColorRatio_Cyan 0.6
#define ColorRatio_Magenta 0.8



// 马赛克
// size         : 纹理的宽高（若是贴图，则是 xxx_TexelSize.zw；若是FullScreen或PostProcess，则是 _ScreenParams.xy）
// intensity    : 强度
// uv           : 当前像素的uv
void Mosaic_float(float2 size, float2 intensity, inout float2 uv)
{
    intensity = max(0.000001, intensity);
    float2 pixel = floor(uv * size / intensity) * intensity;
    uv = pixel / size;
}



// 黑白图
// 区别经验模型代表的Gray灰度。以下算法计算后的灰度要比常规的灰度图在黑白区域对比要更明显
// 若需要使用经验模型的灰度，直接引入Graphi-Color.hlsl，调用Gray函数即可。
// c    : RGB颜色
void BlackWhite_float(inout float3 c)
{
    // 公式： (max - min) * ratioMax + (mid - min) * radioMaxMid + min

    float _max = max(c.r, max(c.g, c.b));
    float _min = min(c.r, min(c.g, c.b));
    float _mid = c.r + c.g + c.b - (_max + _min);

    float radioMaxMid = lerp(ColorRatio_Green, lerp(ColorRatio_Blue, ColorRatio_Red, step(c.b, _min)), step(c.g, _min));
    float ratioMax = lerp(ColorRatio_Red, lerp(ColorRatio_Green, ColorRatio_Blue, step(c.b, _max)), step(c.g, _max));

    float g = (_max - _min) * ratioMax + (_mid - _min) * radioMaxMid + _min;
    c = (g).xxx;
}



// 老照片（发黄）
// c    : RGB颜色
void OldPhotos_float(inout float3 c)
{
    float r = 0.393 * c.r + 0.769 * c.g + 0.189 * c.b;
    float g = 0.349 * c.r + 0.686 * c.g + 0.168 * c.b;
    float b = 0.272 * c.r + 0.534 * c.g + 0.131 * c.b;
    c = float3(r, g, b);
}



// 颜色矩阵滤镜
// m    : 4x4矩阵
// off  : 4x4矩阵偏移数据
// c    : 颜色
void ColorMatrixFilter_float(float4x4 m, float4 off, inout float4 c)
{
    /*
        
             //4x4           off
             R  G   B   A    
          R  1, 0,  0,  0,    0
          G  0, 1,  0,  0,    0
          B  0, 0,  1,  0,    0
          A  0, 0,  0,  1,    0
    */

    float r = m._11 * c.r + m._12 * c.g + m._13 * c.b + m._14 * c.a + off.x;
    float g = m._21 * c.r + m._22 * c.g + m._23 * c.b + m._24 * c.a + off.y;
    float b = m._31 * c.r + m._32 * c.g + m._33 * c.b + m._34 * c.a + off.z;
    float a = m._41 * c.r + m._42 * c.g + m._43 * c.b + m._44 * c.a + off.w;
    c = float4(r,g,b,a);
}


// 浮雕
void Relief_float
(
// input
    Texture2D tex,  // 纹理
    float4 texel,   // 纹理的纹素
    float2 uv,      // 当前uv
    float level,    // 偏移量
    float force,    // 强度
    float rgscale,  // 亮度值
    float2 invert,  // 方向翻转（1：正向；-1：反向）。只支持1和-1
    bool isGray,    // 是否将浮雕设置为灰度
// out
    inout float3 color
)
{
    float2 deltaU = float2(texel.x * level, 0);
    float4 lcolor = SAMPLE_TEXTURE2D(tex, s_trilinear_clamp_sampler, uv - deltaU);
    float l = Gray(lcolor.rgb);
    float4 rcolor = SAMPLE_TEXTURE2D(tex, s_trilinear_clamp_sampler, uv + deltaU);
    float r = Gray(rcolor.rgb);

    float2 deltaV = float2(0, texel.y * level);
    float4 tcolor = SAMPLE_TEXTURE2D(tex, s_trilinear_clamp_sampler, uv + deltaV);
    float t = Gray(tcolor.rgb);
    float4 bcolor = SAMPLE_TEXTURE2D(tex, s_trilinear_clamp_sampler, uv - deltaV);
    float b = Gray(bcolor.rgb);

    float3 tangentU = float3(1, 0, ((r-l)/deltaU.x) * force * invert.x);
    float3 tangentV = float3(0, 1, ((t-b)/deltaV.y) * force * invert.y);
    float3 n = normalize(cross(tangentV, tangentU));
    n *= -1;
    n = n * 0.5 + 0.5; //0-1范围
    n.xy *= rgscale;

    color = (isGray) ? Gray(n) : n;
}


#endif //滤镜（由 Graphi 着色库工具生成）| 作者：强辰