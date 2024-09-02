#ifndef GRAPHI_BLENDCOLOR
#define GRAPHI_BLENDCOLOR

#include "Graphi_Color.hlsl"


// 混合颜色
// c1, c2 : 两个颜色值
// type : 混合类型（请查看 BlendColorKind ShaderGraph 子节点）
// Out : 输出
void BlendColor_float
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


#endif //颜色混合（由 Graphi 着色库工具生成）| 作者：强辰