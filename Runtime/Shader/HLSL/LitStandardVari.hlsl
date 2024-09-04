#ifndef LITSTANDARDVARIANT
#define LITSTANDARDVARIANT

// 引入操作库
#include "NormalBlend.hlsl"
#include "Color.hlsl"


// 纹理采样
float4 SampleTex(UnityTexture2D tex, float2 uvs)
{
	return SAMPLE_TEXTURE2D(tex, tex.samplerstate, tex.GetTransformedUV(uvs));
}



/*
	反照率
*/
void CalculateAlbedo_float
(
// Input
	UnityTexture2D tex,
	float4 clr,
	float detailAlbedoFactor,
	float detailForce,
	float2 uvs,
	float detailMask,
// Output
	out float3 albedo
)
{
	
	float4 c = SampleTex(tex, uvs);
	c *= clr;

	float factor = saturate( abs(detailForce) * detailAlbedoFactor );
	float3 overlayc = lerp(sqrt(c), (detailForce < 0.0) ? float3(0.0, 0.0, 0.0) : float3(1.0, 1.0, 1.0), factor * factor);
	overlayc *= overlayc;

	albedo = lerp( c, overlayc, detailMask );

}



/*
	法线
*/
void CalculateNormal_float
(
// Input
UnityTexture2D tex,
float normalstrength,
float3 detailnormal,
float2 uvs,
float detailmask,
// Output
out float3 normal
)
{
	// 切线空间，采样并解码
	float4 n = SampleTex(tex, uvs);
	n.rgb = UnpackNormal(n);

	// 法线强度处理
	float3 basenormal = float3(n.rg * normalstrength, lerp(1, n.b, saturate(normalstrength)));

	// 混合细节法线（以 Reoriented 方式进行混合）
	float3 blendnormal = BlendNormal_RNM2( basenormal, detailnormal );

	// 细节因子处理
	normal = lerp(basenormal, blendnormal, detailmask);
}




/* 
	混合贴图
*/
void CalculateMADS_float
(
// Input
float smoothdetail,
float smoothdetailForce,
float2 smoothremapping,
float smooth,
bool useremapping,
float2 metalremapping,
float metal,
float2 aoremapping,
float2 uvs,
UnityTexture2D tex,
// Output
out float detailmask,
out float metalness,
out float amocc,
out float smoothness
)
{
// 采样混合贴图获取4个通道的值
	float4 val = SampleTex(tex, uvs);
	detailmask = val.b;

// 是否采用remapping模式
	float isUseremapping = (useremapping) ? 1 : 0;

// 金属度
	metalness = lerp( metal,  lerp(metalremapping.x, metalremapping.y, val.r),  isUseremapping);

// AO
	amocc = lerp( 1,  lerp(aoremapping.x, aoremapping.y, val.g),  isUseremapping );

// 平滑度
	float s = lerp( smooth,  lerp( smoothremapping.x, smoothremapping.y, val.a ),  isUseremapping );
	float factor = saturate( abs(smoothdetail) * smoothdetailForce );
	float overlays = lerp( s,  (smoothdetail < 0.0) ? 0.0 : 1.0,  factor );
	smoothness = lerp( s,  saturate( overlays ), detailmask );
}



/*
	细节贴图
*/
void CalculateDetail_float
(
// Input
bool LockAlbedoTillingAndOffset,
UnityTexture2D DetailTex,
float4 DetailTillingAndOffset,
float2 UVs,
float DetailNormalForce,
float2 BTilling,
float2 BOffset,
// Output
out float albedo,
out float3 normal,
out float smooth
)
{
	float2 DTilling = DetailTillingAndOffset.xy;
	float2 DOffset = DetailTillingAndOffset.zw;


	float2 tilling = DTilling * BTilling;
	tilling = lerp(DTilling, tilling, LockAlbedoTillingAndOffset);

	float2 offsets = DOffset + BOffset;
	offsets = lerp(DOffset, offsets, LockAlbedoTillingAndOffset);

	// 采样细节贴图
	float2 sampleUVs = UVs * tilling + offsets;
	float4 val = SampleTex(DetailTex, sampleUVs);

	// 解析各通道值
	// R: 灰度
	albedo = val.r * 2.0 - 1.0;

	// GA: 法线（G：y、A：x）
	// 计算细节图中的法线信息, 细节图中的法线格式：(?, y, ?, x) 
	real4 n = real4(1, val.g, 0, val.a);
	n.a *= n.r;

	real3 nn;
	nn.xy = n.ag * 2.0 - 1.0;
	nn.z = max(1.0e-16, sqrt(1.0 - saturate(dot(nn.xy, nn.xy))));
	nn.xy *= DetailNormalForce;
	normal = normalize( nn );  

	// B: 平滑度
	smooth = val.b * 2.0 - 1.0;
}



/*
	自发光
*/
void CalculateEmssion_float
(
// Input
float3 AlbedoColor,
bool MultiplyAlbedo,
float4 EmissonColor,
UnityTexture2D EmissionTex,
float3 Exposure,
float ExposureWeight,
float2 SampleUV,
// Output 
out float3 outColor
)
{
	// 计算与自发光颜色相乘的系数
	float3 loc = float3(1,1,1);
	float3 albedo = lerp(loc, AlbedoColor, MultiplyAlbedo);
	
	float3 emissonColor = albedo * EmissonColor;
	emissonColor *= SampleTex(EmissionTex, SampleUV);

	// 计算曝光度影响
	float3 e = lerp( Exposure * emissonColor,  emissonColor,  ExposureWeight );

	// 返回
	outColor = e;
}




/*
	清漆
*/
void CalculateCoat_float
(
//Input
float coat,
UnityTexture2D tex,
float2 uvs,
//Output
out float clearcoat
)
{
	clearcoat = SampleTex(tex, uvs).r * max(1e-10, coat);
}



/*
	半透明折射
*/
void Refraction_float
(
// Input
float2 uvs,
float4 refractionColor,
UnityTexture2D refractionColormap,
float ior,
float absorptionDistance,
float thickness,
bool useThicknessMap,
UnityTexture2D thicknessMap,
float2 thickRange,
// Output
out float IndexOfRefraction,
out float3 TransmittanceColor,
out float AbsorptionDistance,
out float Thickness
)
{
// 折射索引
IndexOfRefraction = ior;

// 吸收光距离
AbsorptionDistance = absorptionDistance;

// 计算透射颜色
TransmittanceColor = ( refractionColor * SampleTex( refractionColormap, uvs ) ).rgb;

// 计算折射厚度
Thickness = (useThicknessMap) ?  ( thickRange.x + thickRange.y * SampleTex( thicknessMap, uvs ).r ) : thickness;
}




/*
	覆盖颜色处理
*/
void CoverColor_float
(
// Input
	bool Flag,
	float4 Clr, 
	UnityTexture2D CoverMap, float2 UVs,
	bool RFlag, bool GFlag, bool BFlag, bool AFlag,
	float4 RColor, float4 GColor, float4 BColor, float4 AColor,
	float RColorBright, float GColorBright, float BColorBright, float AColorBright,
	bool BlendFlag, float BlendType, float BlendFactor,
	float threshold,
// Output	
	out float3 result
)
{
	if(!Flag)
	{// 总开关如果是关闭状态，则直接返回原颜色
		result = Clr.rgb;
		return;
	}

	float4 coverclr = SampleTex(CoverMap, UVs);
	float r = coverclr.r;
	float g = coverclr.g;
	float b = coverclr.b;
	float a = coverclr.a;

	// 覆盖色贴图中灰度值小于阔值的，则进行忽略。若不进行处理，后续操作会因为灰度值较低，导致破点（黑块）的形成。若贴图分辨率不高，破点的面积会变大。
	r = (RFlag) ? (r < threshold ? 0 : r) : 0;
	g = (GFlag) ? (g < threshold ? 0 : g) : 0;
	b = (BFlag) ? (b < threshold ? 0 : b) : 0;
	a = (AFlag) ? (a < threshold ? 0 : a) : 0;

	if(r+g+b+a == 0)
	{// 4通道的因子相加为0，说明此处像素没有覆盖色
		result = Clr.rgb;
		return;
	}


	float3 orign = Clr.rgb;
	float3 gray = Gray(orign);

	float3 cr = RFlag ? RColor.rgb * gray * RColorBright : orign;
	float3 cg = GFlag ? GColor.rgb * gray * GColorBright : orign;
	float3 cb = BFlag ? BColor.rgb * gray * BColorBright : orign;
	float3 ca = AFlag ? AColor.rgb * gray * AColorBright : orign;

	cr *= r;
	cg *= g;
	cb *= b;
	ca *= a;


	if(BlendFlag)
	{
		// 覆盖色重叠区域的颜色混合处理
		// =============================目前没有想到更好的判断方式，暂时先用 if...else 编写==================================
		float4 blendcolor = (r != 0) ? float4(cr, 1) : 0;
		if(g != 0)
		{
			if(ZeroColor(blendcolor)){ blendcolor = float4(cg,1);}
			else { BlendColorNode_float( blendcolor, float4(cg,1), BlendType, BlendFactor, blendcolor ); }
		}
		if(b != 0)
		{
			if(ZeroColor(blendcolor)){ blendcolor = float4(cb,1);}
			else { BlendColorNode_float( blendcolor, float4(cb,1), BlendType, BlendFactor, blendcolor ); }
		}
		if(a != 0)
		{
			if(ZeroColor(blendcolor)) { blendcolor = float4(ca,1); }
			else { BlendColorNode_float( blendcolor, float4(ca,1), BlendType, BlendFactor, blendcolor ); }
		}
		// ===============================================结束=========================================================

		result = blendcolor.rgb;
	}
	else
	{
		result = cr + cg + cb + ca;
	}
}



#endif //Lit Standard 标准光照变体着色器（由 Graphi 着色库工具生成）| 作者：强辰