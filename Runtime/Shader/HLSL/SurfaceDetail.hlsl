#ifndef SURFACEDETAIL
#define SURFACEDETAIL


#include "Normal.hlsl"
#include "Tex.hlsl"



///
// 表面细节混合处理
///
void DetailHybrid_float
(
// 基础采样参数
float3 posOS, float3 posWS, UnityTexture2D t2d, float3 normalWS, float tile, float triblend,
// 细节采样参数
UnityTexture2D detailT2d, float2 uv,
// 计算相关的参数
float4 maincolor, float4 tintcolor, float4 detailcolor, float dirtforce,
float smoothness, float detailsmooth, float metalness, float detailmetalness,
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



/*
	表面法线细节置换
*/
void NormalDisplacement_float
(
// normal
float2 uv,
UnityTexture2D BaseNormalTex,
UnityTexture2D DetailNormalTex,
float normalforce,
// coat
UnityTexture2D Coatmap,
float coat,
// calucation
UnityTexture2D DirtRoughnessMap,
UnityTexture2D DetailMaskMap,
float4 _BaseColor,
float4 _BaseColorOverlay,
float4 _BaseDirtColor,
float4 _DetailColor,
float _BaseSmoothness,
float _BaseDirtStrength,
float _BaseMetallic,
float _DetailEdgeWear,
float _DetailEdgeSmoothness,
float _DetailDirtStrength,
float _DetailOcclusionStrength,
// output
out float3 N,
out float CoatMsk,
out float3 Albedo,
out float Metallic,
out float Smoothness,
out float Occ,
out float Alpha
)
{
// 法线计算
	float3 BaseNormal = UnpackNormal( SampleTex(BaseNormalTex, uv) );
	float3 DetailNormal = UnpackNormal( SampleTex(DetailNormalTex, uv) );
	float3 baseNormal = lerp(  float3(0,0,1),  BaseNormal,  normalforce );

	float val1 = clamp( uv.x - 0.92, 0.0, 1.0 );
	float val2 = clamp( uv.y - 0.92, 0.0, 1.0 );
	float factor = ceil( val1 ) * ceil( val2 );

	N = lerp( DetailNormal,  baseNormal,  factor );

// 清漆
	CoatMsk = SampleTex(Coatmap, uv).r * coat;

// 反照率计算
	float4 dirtRoughness_sample = SampleTex(DirtRoughnessMap, uv);
	float4 detailmask_sample = SampleTex(DetailMaskMap, uv);

	float clampResult77 = clamp( pow( dirtRoughness_sample.g,  _BaseDirtStrength ), 0.0, 1.0  );
	float4 lerpResult76 = lerp( _BaseDirtColor, float4( 1, 1, 1, 0 ),  clampResult77 );
	float4 lerpResult71  = lerp( _BaseColor,  _BaseColorOverlay,  dirtRoughness_sample.r );
	float4 lerpResult134 = lerp( lerpResult71,  _DetailColor,  ceil( (  ( 1.0 - detailmask_sample.b ) - 0.95 ) ) );
	float  temp_output_120_0  =  ceil(  (  detailmask_sample.b  -  0.8  )  );
	float4 lerpResult123  =  lerp(  lerpResult134,  float4( float3( 1, 0.95, 0.9 ), 0.0 ),  temp_output_120_0 );
	float  clampResult49  =  clamp( pow( ( detailmask_sample.r  + 0.55 ), 6.0 ), 0.0,  1.0  );
	float4  lerpResult92  =  lerp( lerpResult123, ( lerpResult123 * clampResult49 ),  _DetailDirtStrength );
	float  clampResult62  =  clamp( ( ( detailmask_sample.r  -  0.55 ) * 2.0 ),  0.0,  1.0 );
	float4 clampResult101 = clamp( ( clampResult62 + lerpResult92 ),  float4( 0, 0, 0, 0 ),  float4( 1, 1, 1, 0 ) );
	float4  lerpResult32  =  lerp( lerpResult92,  clampResult101,  _DetailEdgeWear );
	Albedo = ( lerpResult76 * lerpResult32 ).rgb;

// 金属度
	float lerpResult94  =  lerp( 0.0,  clampResult62,  _DetailEdgeWear );
	float clampResult97  =  clamp( ( lerpResult94 + temp_output_120_0 ),  0.0,  1.0  );
	Metallic = clamp( (  clampResult97  +  _BaseMetallic ),  0.0,  1.0 );

// 平滑度
	float4  lerpResult121  =  
	lerp( ( ( max( clampResult62,  dirtRoughness_sample.a )  *  lerpResult76 )  * _BaseSmoothness ),   _DetailEdgeSmoothness.xxxx,  clampResult97  );
	Smoothness  =  lerpResult121.r ;

// AO
	Occ  =  lerp ( 1.0,  detailmask_sample.g,   _DetailOcclusionStrength );

// Alpha
	Alpha = 1;
}





/*
	表面法线细节混合
*/
void NormalBlend_float
(
// normal
	float2 uv,
	UnityTexture2D BaseNormal,
	UnityTexture2D DetailNormal,
	float normalforce,
	float normalblendtype,
// coat
	UnityTexture2D CoatMap,
	float coat,
// blend
	UnityTexture2D dirtRoughnessMap,
	UnityTexture2D detailmaskMap,
	float4 _BaseColor,
	float4 _BaseColorOverlay,
	float4 _BaseDirtColor,
	float4 _DetailColor,
	float _BaseSmoothness,
	float _BaseDirtStrength,
	float _BaseMetallic,
	float _DetailEdgeWear,
	float _DetailEdgeSmoothness,
	float _DetailDirtStrength,
	float _DetailOcclusionStrength,
// output
	out float3 N,
	out float CoatMsk,
	out float3 Albedo,
	out float Metallic,
	out float Smoothness,
	out float Occ,
	out float Alpha
)
{
	// 法线
	float3 basenormal = UnpackNormal(SampleTex(BaseNormal, uv));
	basenormal = lerp(float3(0,0,1), basenormal, normalforce);
	float3 detailnormal = UnpackNormal(SampleTex(DetailNormal, uv));
	BlendNormalDeal_float(detailnormal, basenormal, normalblendtype, N);

	// 清漆
	CoatMsk = SampleTex(CoatMap, uv).r * coat;

	// 采样
	float4 dirtRoughness_sample = SampleTex(dirtRoughnessMap, uv);
	float4 detailmask_sample = SampleTex(detailmaskMap, uv);

	// 反照率计算
	float clampResult77 = clamp( pow( dirtRoughness_sample.g , _BaseDirtStrength ) , 0.0 , 1.0 );
	float4 lerpResult76 = lerp( _BaseDirtColor , float4( 1,1,1,0 ) , clampResult77);
	float4 lerpResult71 = lerp( _BaseColor , _BaseColorOverlay , dirtRoughness_sample.r);
	float4 lerpResult134 = lerp( lerpResult71 , _DetailColor , ceil( ( ( 1.0 - detailmask_sample.b ) + -0.95 ) ));
	float temp_output_120_0 = ceil( ( detailmask_sample.b + -0.8 ) );
	float4 lerpResult123 = lerp( lerpResult134 , float4( float3(1,0.95,0.9) , 0.0 ) , temp_output_120_0);
	float clampResult49 = clamp( pow( ( detailmask_sample.r + 0.55 ) , 6.0 ) , 0.0 , 1.0 );
	float4 lerpResult92 = lerp( lerpResult123 , ( lerpResult123 * clampResult49 ) , _DetailDirtStrength);
	float clampResult62 = clamp( ( ( detailmask_sample.r + -0.55 ) * 2.0 ) , 0.0 , 1.0 );
	float4 clampResult101 = clamp( ( clampResult62 + lerpResult92 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
	float4 lerpResult32 = lerp( lerpResult92 , clampResult101 , _DetailEdgeWear);
	Albedo = ( lerpResult76 * lerpResult32 ).rgb;

	// 金属度
	float lerpResult94 = lerp( 0.0 , clampResult62 , _DetailEdgeWear);
	float clampResult97 = clamp( ( lerpResult94 + temp_output_120_0 ) , 0.0 , 1.0 );
	Metallic = clamp( ( clampResult97 + _BaseMetallic ) , 0.0 , 1.0 );

	// 平滑度
	float4 lerpResult121 = 
	lerp( ( ( max( clampResult62 , dirtRoughness_sample.a ) * lerpResult76 ) * _BaseSmoothness ) , _DetailEdgeSmoothness.xxxx , clampResult97);
	Smoothness = lerpResult121.r;

	// AO
	Occ  =  lerp( 1.0 , detailmask_sample.g , _DetailOcclusionStrength);

	// Alpha
	Alpha = 1;
}









#endif //表面细节处理（由 Graphi 着色库工具生成）| 作者：强辰