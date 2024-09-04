#ifndef GRAPHI_COLOR
#define GRAPHI_COLOR


// RGBA ��һ������0-255��ֵתΪ0-1��
float4 RGBAtoNormalize(float4 c)
{
	return c * 0.003;
}


// �Ҷ�
float3 Gray(float3 c)
{
	float val = dot(c.rgb, float3(0.299, 0.587, 0.114)); //float3(0.2126,0.7152, 0.0722);  float3(0.299, 0.587, 0.114)
	return val.xxx;
}


// �Զ���Ҷ�
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


// ȡ��
float3 Negation(float3 c){ return 1 - c.rgb; }


// ��ȡ���ص�����ֵ
// c			: ����
// threshold	: ������ֵ
float4 Lumi(float4 c, float threshold)
{
	float _threshold = threshold;
	float _thresholdhalf = _threshold * 0.5;
	float brightness = Max3(c.r, c.g, c.b); // ��ȡ����RGBͨ���ϴ��ֵ��Ϊ���Ȳο�ֵ

	// ͨ����������ֵ������˥�������ķ�����
	// ˥��������㣺
	//		С����ֵ̫�࣬�޸�Ϊ��ɫ��
	//		��С����ֵ��Χ�ڣ�΢����Դɫ��
	//		������ֵ����ִ��˥��������
	float area = clamp(brightness - _threshold + _thresholdhalf, 0.0, 2.0 * _thresholdhalf);
	area = (area * area) / (4.0 * _thresholdhalf + 1e-4);

	// ����˥��
	float atten = max(brightness - _threshold, area) / max(brightness, 1e-4);
	
	// ��������ֵ
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


// RGB ת HSV ��ɫ
float3 RGB_HSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


// HSV ת RGB ��ɫ
float3 HSV_RGB(float3 c)
{
    float3 rgb = clamp( abs(fmod(c.x*6.0+float3(0.0,4.0,2.0),6)-3.0)-1.0, 0, 1);
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * lerp( float3(1,1,1), rgb, c.y);
}


// �Բ�����ɫ����ɫ�ࡢ���Ͷȡ����ȡ��Աȶȵ���
// clr : ��ɫ
// h��ɫ��ı仯������Χ[0-1]
// s: ���Ͷȱ仯������Χ[0-n]
// b: ���ȱ仯������Χ[0-n]
// c: �Աȶȱ仯������Χ[0-n]
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


// �Բ�����ɫ���� ���ȡ����Ͷȡ��Աȶ� �ĵ���
float4 Hue(float4 clr, float brightness, float saturation, float contrast)
{
	float3 c = clr.rgb;

	// ������
	c *= brightness;

	// ���Ͷ�
	float lum = Luminance0(c); //ȡ������ֵ
	c = lerp(lum.xxx, c, saturation);

	// �Աȶ�
	float3 avg = float3(0.5, 0.5, 0.5);
	c = lerp(avg, c, contrast);

	clr.rgb = c;
	return clr;
}


// �Բ���1��ɫ����ƫɫ��
// orign : ��ƫɫ����ɫ
// changeClr : ƫɫ
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


// �жϲ�����ɫ�Ƿ�Ϊ0
bool ZeroColor(float4 c){ return c.r+c.g+c.b+c.a == 0; }



// ////////////////////////////////////////////////////////
// ��ɫ���


// ����
void BlendColor_Burn(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out =  1.0 - (1.0 - c2)/(c1 + 0.000000000001);
    Out = lerp(c1, Out, factor);
}


// ���Լ���
void BlendColor_LinearBurn(float4 c1, float4 c2, float factor, out float4 Out)
{
	Out = c1 + c2 - 1.0;
    Out = lerp(c1, Out, factor);
}


// �䰵
void BlendColor_Darken(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = min(c2, c1);
    Out = lerp(c1, Out, factor);
}


// ����
void BlendColor_Overwrite(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = lerp(c1, c2, factor);
}


// ��Ƭ����
void BlendColor_Overlay(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 result1 = 1.0 - 2.0 * (1.0 - c1) * (1.0 - c2);
    float4 result2 = 2.0 * c1 * c2;
    float4 zeroOrOne = step(c1, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// ����
void BlendColor_Lighten(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = max(c2, c1);
    Out = lerp(c1, Out, factor);
}


// ����
void  BlendColor_VividLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    c1 = clamp(c1, 0.000001, 0.999999);
    float4 result1 = 1.0 - (1.0 - c2) / (2.0 * c1);
    float4 result2 = c2 / (2.0 * (1.0 - c1));
    float4 zeroOrOne = step(0.5, c1);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// ���Թ�
void BlendColor_LinearLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c2 < 0.5 ? max(c1 + (2 * c2) - 1, 0) : min(c1 + 2 * (c2 - 0.5), 1);
    Out = lerp(c1, Out, factor);
}


// ���
void BlendColor_Multiply(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 * c2;
    Out = lerp(c1, Out, factor);
}


// ��ȥ
void BlendColor_Subtract(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 - c2;
    Out = lerp(c1, Out, factor);
}


// ���
void BlendColor_Divide(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 / (c2 + 0.000000000001); //1e-16
    Out = lerp(c1, Out, factor);
}


// ��ֵ
void BlendColor_Difference(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = abs(c2 - c1);
    Out = lerp(c1, Out, factor);
}


// �ų�
void BlendColor_Exclusion(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c2 + c1 - (2.0 * c2 * c1);
    Out = lerp(c1, Out, factor);
}


// ȡ��
void BlendColor_Negation(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = 1.0 - abs(1.0 - c2 - c1);
    Out = lerp(c1, Out, factor);
}


// ���Լ���
void BlendColor_LinearDodge(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 + c2;
    Out = lerp(c1, Out, factor);
}


// ���Լ�������ӣ�
void BlendColor_LinearLightAddSub(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c2 + 2.0 * c1 - 1.0;
    Out = lerp(c1, Out, factor);
}


// ���
void BlendColor_SoftLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 result1 = 2.0 * c1 * c2 + c1 * c1 * (1.0 - 2.0 * c2);
    float4 result2 = sqrt(c1) * (2.0 * c2 - 1.0) + 2.0 * c1 * (1.0 - c2);
    float4 zeroOrOne = step(0.5, c2);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// ���
void BlendColor_HardMix(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = step(1 - c1, c2);
    Out = lerp(c1, Out, factor);
}


// �ֲ��ڹ�
void BlendColor_Dodge(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 / (1.0 - clamp(c2, 0.000001, 0.999999));
    Out = lerp(c1, Out, factor);
}


// ǿ��
void BlendColor_HardLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 result1 = 1.0 - 2.0 * (1.0 - c1) * (1.0 - c2);
    float4 result2 = 2.0 * c1 * c2;
    float4 zeroOrOne = step(c2, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(c1, Out, factor);
}


// ���
void BlendColor_PinLight(float4 c1, float4 c2, float factor, out float4 Out)
{
    float4 check = step (0.5, c2);
    float4 result1 = check * max(2.0 * (c1 - 0.5), c2);
    Out = result1 + (1.0 - check) * min(2.0 * c1, c2);
    Out = lerp(c1, Out, factor);
}


// ��ɫ
void BlendColor_Filter(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = 1.0 - (1.0 - c2) * (1.0 - c1);
    Out = lerp(c1, Out, factor);
}


// ���
void BlendColor_Add(float4 c1, float4 c2, float factor, out float4 Out)
{
    Out = c1 + c2;
    Out = lerp(c1, Out, factor);
}



// �����ɫ
// c1, c2 : ������ɫֵ
// type : ������ͣ���鿴 ShaderGraph �ӽڵ㣩
// Out : ���
void BlendColorNode_float
(
// ����
	float4 c1,
	float4 c2, 
	float type, 
	float factor, 
// ���
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

// ����
// ////////////////////////////////////////////////////////


#endif //��ɫ��ز������� Graphi ��ɫ�⹤�����ɣ�| ���ߣ�ǿ��