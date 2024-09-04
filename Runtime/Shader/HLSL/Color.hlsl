#ifndef GRAPHI_COLOR
#define GRAPHI_COLOR


// RGBA 归一化（将0-255的值转为0-1）
float4 RGBAtoNormalize(float4 c)
{
	return c * 0.003;
}


// 灰度
float3 Gray(float3 c)
{
	float val = dot(c.rgb, float3(0.299, 0.587, 0.114)); //float3(0.2126,0.7152, 0.0722);  float3(0.299, 0.587, 0.114)
	return val.xxx;
}


// 自定义灰度
void GrayCustom_float
(
// input
float3 inputc,
float r,
float g,
float b,
// output
out float val
)
{
    val = dot(inputc.rgb, float3(r,g,b));
}


// 取反
float3 Negation(float3 c){ return 1 - c.rgb; }


// 提取像素的亮度值
// c			: 像素
// threshold	: 亮度阔值
float4 Lumi(float4 c, float threshold)
{
	float _threshold = threshold;
	float _thresholdhalf = _threshold * 0.5;
	float brightness = Max3(c.r, c.g, c.b); // 获取像素RGB通道较大的值作为亮度参考值

	// 通过亮度与阔值，计算衰减操作的分子项
	// 衰减区间计算：
	//		小于阔值太多，修改为黑色；
	//		在小于阔值范围内，微弱的源色；
	//		大于阔值，则执行衰减除法；
	float area = clamp(brightness - _threshold + _thresholdhalf, 0.0, 2.0 * _thresholdhalf);
	area = (area * area) / (4.0 * _thresholdhalf + 1e-4);

	// 计算衰减
	float atten = max(brightness - _threshold, area) / max(brightness, 1e-4);
	
	// 最终亮度值
	float4 final = float4(c.rgb * atten, c.a);
	return final;
}
real Luminance0(real3 c)
{
    return dot(c, real3(0.2126729, 0.7151522, 0.0721750));
}
real Luminance0(real4 c)
{
    return Luminance0(c.rgb);
}


// RGB 转 HSV 颜色
float3 RGB_HSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


// HSV 转 RGB 颜色
float3 HSV_RGB(float3 c)
{
    float3 rgb = clamp( abs(fmod(c.x*6.0+float3(0.0,4.0,2.0),6)-3.0)-1.0, 0, 1);
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * lerp( float3(1,1,1), rgb, c.y);
}


// 对参数颜色进行色相、饱和度、明度、对比度调节
// clr : 颜色
// h：色相的变化量，范围[0-1]
// s: 饱和度变化量，范围[0-n]
// b: 明度变化量，范围[0-n]
// c: 对比度变化量，范围[0-n]
void HSBC_float(float3 clr, float h, float s, float b, float c, out float3 Out)
{
	float3 hsv = RGB_HSV(clr);
    
    hsv.x += clamp(h, 0, 1);
    hsv.y *= s;//clamp(s, 0, 1);
    hsv.z *= b;//clamp(c, 0, 1);

    float3 rgb = HSV_RGB(hsv);

    float3 avg = float3(0.5,0.5,0.5);
    rgb = lerp(avg, rgb, c);

	Out = rgb;
}


// 对参数颜色进行 亮度、饱和度、对比度 的调节
float4 Hue(float4 clr, float brightness, float saturation, float contrast)
{
	float3 c = clr.rgb;

	// 明亮度
	c *= brightness;

	// 饱和度
	float lum = Luminance0(c); //取出亮度值
	c = lerp(lum.xxx, c, saturation);

	// 对比度
	float3 avg = float3(0.5, 0.5, 0.5);
	c = lerp(avg, c, contrast);

	clr.rgb = c;
	return clr;
}


// 对参数1颜色进行偏色。
// orign : 被偏色的颜色
// changeClr : 偏色
float3 ColourCast(float3 orign, float3 changeClr)
{
	float3 orignHsv = RGB_HSV(orign);
	float3 hsv = RGB_HSV(changeClr);

	float3 newhsv = float3
	(
		hsv.x, 
		orignHsv.y * hsv.y,
		orignHsv.z * hsv.z
	);

	return HSV_RGB(newhsv);
}


// 判断参数颜色是否为0
bool ZeroColor(float4 c){ return c.r+c.g+c.b+c.a == 0; }



// ////////////////////////////////////////////////////////
// 颜色混合


// 加深
void BlendColor_Burn(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out =  1.0 - (1.0 - c2)/(c1 + 0.000000000001);
    Out = lerp(c1, Out, factor);
}


// 线性加深
void BlendColor_LinearBurn(float4 c1, float4 c2, float factor, out float4 Out)
{
	Out = c1 + c2 - 1.0;
    Out = lerp(c1, Out, factor);
}


// 变暗
void BlendColor_Darken(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = min(c2, c1);
    Out = lerp(c1, Out, factor);
}


// 覆盖
void BlendColor_Overwrite(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = lerp(c1, c2, factor);
}


// 正片叠底
void BlendColor_Overlay(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 result1 = 1.0 - 2.0 * (1.0 - c1) * (1.0 - c2);
    float4 result2 = 2.0 * c1 * c2;
    float4 zeroOrOne = step(c1, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// 变亮
void BlendColor_Lighten(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = max(c2, c1);
    Out = lerp(c1, Out, factor);
}


// 亮光
void  BlendColor_VividLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    c1 = clamp(c1, 0.000001, 0.999999);
    float4 result1 = 1.0 - (1.0 - c2) / (2.0 * c1);
    float4 result2 = c2 / (2.0 * (1.0 - c1));
    float4 zeroOrOne = step(0.5, c1);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// 线性光
void BlendColor_LinearLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c2 < 0.5 ? max(c1 + (2 * c2) - 1, 0) : min(c1 + 2 * (c2 - 0.5), 1);
    Out = lerp(c1, Out, factor);
}


// 相乘
void BlendColor_Multiply(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 * c2;
    Out = lerp(c1, Out, factor);
}


// 减去
void BlendColor_Subtract(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 - c2;
    Out = lerp(c1, Out, factor);
}


// 相除
void BlendColor_Divide(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 / (c2 + 0.000000000001); //1e-16
    Out = lerp(c1, Out, factor);
}


// 差值
void BlendColor_Difference(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = abs(c2 - c1);
    Out = lerp(c1, Out, factor);
}


// 排除
void BlendColor_Exclusion(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c2 + c1 - (2.0 * c2 * c1);
    Out = lerp(c1, Out, factor);
}


// 取反
void BlendColor_Negation(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = 1.0 - abs(1.0 - c2 - c1);
    Out = lerp(c1, Out, factor);
}


// 线性减淡
void BlendColor_LinearDodge(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 + c2;
    Out = lerp(c1, Out, factor);
}


// 线性减淡（添加）
void BlendColor_LinearLightAddSub(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c2 + 2.0 * c1 - 1.0;
    Out = lerp(c1, Out, factor);
}


// 柔光
void BlendColor_SoftLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 result1 = 2.0 * c1 * c2 + c1 * c1 * (1.0 - 2.0 * c2);
    float4 result2 = sqrt(c1) * (2.0 * c2 - 1.0) + 2.0 * c1 * (1.0 - c2);
    float4 zeroOrOne = step(0.5, c2);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// 混合
void BlendColor_HardMix(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = step(1 - c1, c2);
    Out = lerp(c1, Out, factor);
}


// 局部遮光
void BlendColor_Dodge(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 / (1.0 - clamp(c2, 0.000001, 0.999999));
    Out = lerp(c1, Out, factor);
}


// 强光
void BlendColor_HardLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 result1 = 1.0 - 2.0 * (1.0 - c1) * (1.0 - c2);
    float4 result2 = 2.0 * c1 * c2;
    float4 zeroOrOne = step(c2, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// 点光
void BlendColor_PinLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 check = step (0.5, c2);
    float4 result1 = check * max(2.0 * (c1 - 0.5), c2);
    Out = result1 + (1.0 - check) * min(2.0 * c1, c2);
    Out = lerp(c1, Out, factor);
}


// 滤色
void BlendColor_Filter(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = 1.0 - (1.0 - c2) * (1.0 - c1);
    Out = lerp(c1, Out, factor);
}


// 相加
void BlendColor_Add(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 + c2;
    Out = lerp(c1, Out, factor);
}



// 混合颜色
// c1, c2 : 两个颜色值
// type : 混合类型（请查看 ShaderGraph 子节点）
// Out : 输出
void BlendColorNode_float
(
// 输入
	float4 c1,
	float4 c2, 
	float type, 
	float factor, 
// 输出
	out float4 Out
)
{

	if(type == 0)
		BlendColor_Burn(c1, c2, factor, Out);

	else if(type == 1)
		BlendColor_LinearBurn(c1, c2, factor, Out);

	else if(type == 2)
		BlendColor_Darken(c1, c2, factor, Out);

	else if(type == 3)
		BlendColor_Overwrite(c1, c2, factor, Out);

	else if(type == 4)
		BlendColor_Overlay(c1, c2, factor, Out);

	else if(type == 5)
		BlendColor_Lighten(c1, c2, factor, Out);

	else if(type == 6)
		BlendColor_VividLight(c1, c2, factor, Out);

	else if(type == 7)
		BlendColor_LinearLight(c1, c2, factor, Out);

	else if(type == 8)
		BlendColor_Multiply(c1, c2, factor, Out);

	else if(type == 9)
		BlendColor_Subtract(c1, c2, factor, Out);

	else if(type == 10)
		BlendColor_Divide(c1, c2, factor, Out);

	else if(type == 11)
		BlendColor_Difference(c1, c2, factor, Out);

	else if(type == 12)
		BlendColor_Exclusion(c1, c2, factor, Out);

	else if(type == 13)
		BlendColor_Negation(c1, c2, factor, Out);

	else if(type == 14)
		BlendColor_LinearDodge(c1, c2, factor, Out);

	else if(type == 15)
		BlendColor_LinearLightAddSub(c1, c2, factor, Out);

	else if(type == 16)
		BlendColor_SoftLight(c1, c2, factor, Out);

	else if(type == 17)
		BlendColor_HardMix(c1, c2, factor, Out);

	else if(type == 18)
		BlendColor_Dodge(c1, c2, factor, Out);

	else if(type == 19)
		BlendColor_HardLight(c1, c2, factor, Out);

	else if(type == 20)
		BlendColor_PinLight(c1, c2, factor, Out);

	else if(type == 21)
		BlendColor_Filter(c1, c2, factor, Out);

	else if(type == 22)
		BlendColor_Add(c1, c2, factor, Out);

	else 
		Out = c1;
}

// 结束
// ////////////////////////////////////////////////////////


#endif //颜色相关操作（由 Graphi 着色库工具生成）| 作者：强辰