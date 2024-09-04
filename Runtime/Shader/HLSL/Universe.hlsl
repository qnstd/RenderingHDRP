#ifndef PLANET
#define PLANET

// 引入需要的库文件
#include "Tex.hlsl"
#include "NormalBlend.hlsl"


/*
	月球
*/
void CalculationMoon_float
(
// input
float4 DetailSample, float4 DetailTint, float DetailPow, float DetailForce, float4 AlbedoSample, float4 AlbedoTint, 
// out
out float4 Out
)
{
	float4 powResult = pow( DetailSample.gggg, DetailPow );
	float4 mulResult = powResult * DetailForce;
	float4 detailResult = DetailTint  *  mulResult ;
	float4 albedoResult = AlbedoSample.rrrr  *  AlbedoTint;
	Out = albedoResult + detailResult;
}



/*
	计算太阳外圈活动效果
*/
void CalcuationSunVertWave_float
(
// input
float3 posOS, float3 nWS, float3 viewWS, float VertexFresnelPow, float AnimSpeed, float Amp, float Tile, 
// out
out float3 Position
)
{
	float VdotN = dot( nWS, normalize( viewWS ) ) ;
	float VdotN_Pow = pow( 1 -  abs( VdotN ), VertexFresnelPow ) ;

	float3 n = nWS  * Tile;
	float3 Wave = sin( n + (AnimSpeed * _Time.x) ) * Amp ;

	Position = posOS + VdotN_Pow * Wave ;
}



/*
	计算太阳内圈活动效果
*/
void CalcuationSunInner_float
(
// input
float3 posOS,
float3 normalWS,
float TwistSpeed,
UnityTexture2D T2d,
float TwistUVTile,
float TwistForce,
float FloatSpeed,
float texRUVTile,
float texGUVTile,
float texSamplePow,
float4 ColorOut,
float4 ColorInner,
// out
out float4 Result
)
{
	float twistspeed =  TwistSpeed * _Time.y;
	float3 twistPosUV = float3( posOS.xy  +  twistspeed, posOS.z ) ;

	float4 twistSample = 0;
	TexSampleTriplanar_float(T2d, twistPosUV, normalWS, TwistUVTile, 1.0, twistSample);
	twistSample = twistSample.bbbb;

	float3 samplePosUV = posOS + twistSample * TwistForce;
	samplePosUV += FloatSpeed  *  _Time.y;

	float4 texR = 0;
	TexSampleTriplanar_float(T2d, samplePosUV, normalWS, texRUVTile, 1.0, texR);

	float4 texG = 0;
	TexSampleTriplanar_float(T2d, posOS, normalWS, texGUVTile, 1.0, texG);

	float4 ocolor = texR.r * ColorOut;
	float4 icolor = texG.g * ColorInner;
	Result = SafePositivePow_float( ocolor + icolor,  texSamplePow );
}



/*
	通用行星计算
*/
void CalucationPlanetary_float
(
// input surface
float3 posOS,
float3 normalWS,
float3 tangentWS,
UnityTexture2D albedotex,
float4 color,
UnityTexture2D normaltex,
float normalForce,
float uvtile,
float blendweight,
// input detail
float4 detailcolor,
UnityTexture2D detailtex,
UnityTexture2D detailtex_normal,
float detailuvtile,
float detailblendweight,
float albedoscale,
float normalscale,
float smoothscale,
// input pbr
float metalness,
float smoothness,
// out
out float4 albedo,
out float3 normalTS,
out float m,
out float s
)
{
	// 细节处理
	float3 detail_normal = 0;
	NormalTexSampleTriplanar_float(detailtex_normal, posOS, normalWS, tangentWS, detailuvtile, detailblendweight, normalscale, detail_normal);

	float4 detail = 0;
	TexSampleTriplanar_float(detailtex, posOS, normalWS, detailuvtile, detailblendweight, detail);
	float detail_rgb = detail.r; // 细节灰度
	float detail_mask = detail.g; // 细节遮罩
	float detail_smooth = detail.b; // 平滑度
	

	// 反照率
	TexSampleTriplanar_float(albedotex, posOS, normalWS, uvtile, blendweight, albedo);
	albedo *= color;
	float albedoFactor = saturate( abs(detail_rgb) * albedoscale );
	float3 albedoOverlay = lerp( sqrt(albedo), (detail_rgb < 0.0) ? float3(0.0, 0.0, 0.0) : float3(1.0, 1.0, 1.0), albedoFactor * albedoFactor );
	albedoOverlay *= albedoOverlay;
	albedo = lerp(albedo, float4(albedoOverlay, 1.0) * detailcolor, detail_mask);

	// 法线
	NormalTexSampleTriplanar_float(normaltex, posOS, normalWS, tangentWS, uvtile, blendweight, normalForce, normalTS);
	float3 normalBlend = BlendNormal_RNM2( normalTS, detail_normal );
	normalTS = lerp(normalTS, normalBlend, detail_mask);

	// 平滑度
	float smoothFactor = saturate( abs(detail_smooth) * smoothscale );
	float smoothOverlay = saturate( lerp( smoothness, (detail_smooth < 0.0) ? 0.0 : 1.0, smoothFactor ) );
	s = lerp( smoothness, smoothOverlay, detail_mask );

	// 金属度
	m = metalness;
}



/*
	光环
*/
void Ring_float
(
// input
float4 c,
UnityTexture2D t2d,
float2 uv,
float force,
float outring,
float innerring,
float ringpow,
// out
out float3 Result,
out float Alp
)
{
	float2 center = float2(0.5, 0.5);
	float len = length(uv - center);
	float factor1 = pow(smoothstep(0.5, outring, len), 1);
	float factor2 = pow(smoothstep(innerring, 0.5, len), 1);
	float factor = factor1 * factor2;
	float2 sampleuv = (factor).xx;
	Result = pow(factor.xxx, ringpow) * SAMPLE_TEXTURE2D(t2d.tex, t2d.samplerstate, t2d.GetTransformedUV(sampleuv)) * c * force;
	Alp = 1;
}



#endif //星球、恒星相关计算（由 Graphi 着色库工具生成）| 作者：强辰