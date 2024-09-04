#ifndef SURFACEDETAIL
#define SURFACEDETAIL


#include "Tex.hlsl"

///
// 表面细节混合处理
///
void DetailHybrid_float
(
// 基础采样参数
float3 posOS,
float3 posWS,
UnityTexture2D t2d,
float3 normalWS,
float tile,
float triblend,
// 细节采样参数
UnityTexture2D detailT2d,
float2 uv,
// 计算相关的参数
float4 maincolor,
float4 tintcolor,
float4 detailcolor,
float dirtforce,
float smoothness,
float detailsmooth,
float metalness,
float detailmetalness,
// 法线
UnityTexture2D normalmap,
// output
out float4 Albedo,
out float Metallic,
out float Smooth,
out float AO,
out float3 N
)
{
	// 采样
	float3 pos = float3(0,0,0);
	#if defined( _SAMPLESPACE_OBJECT )
		pos  =  posOS ;
	#else
		pos  =  posWS ;
	#endif
	float4 baseSample = 0;
	TexSampleTriplanar_float(t2d, pos, normalWS, tile, triblend, baseSample);

	float4 detailSample = SampleTex(detailT2d, uv);

	// 反照率
	float4 lerpResultColor01 = lerp(maincolor, tintcolor, baseSample.g);
	float4 lerpResultColor02 = lerp(lerpResultColor01, detailcolor, detailSample);
	float4 mulResult01 = mul(lerpResultColor01, baseSample.r);
	Albedo = lerp( lerpResultColor02, mulResult01, dirtforce );

	// 平滑度
	float lerpResult03 = lerp( 1,  baseSample.r, dirtforce  );
	float mulResult02 = mul(  lerpResult03, baseSample.a  );
	float mulResult03 = mul(  mulResult02, smoothness  );
	float clampResult01 = clamp(  mulResult03, 0, 0.98 );
	Smooth = lerp(  clampResult01,  detailsmooth,  detailSample.r  );

	// 金属度
	Metallic = lerp(metalness,  detailmetalness,  detailSample.r);

	// AO
	AO = detailSample.a;

	// 法线
	N = UnpackNormal(SampleTex(normalmap, uv));
}

#endif //表面细节处理（由 Graphi 着色库工具生成）| 作者：强辰