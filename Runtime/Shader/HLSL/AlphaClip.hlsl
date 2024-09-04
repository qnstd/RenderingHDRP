#ifndef ALPHACLIP
#define ALPHACLIP

// include
#include "Tex.hlsl"


void ClipColor_float
(
UnityTexture2D t2d,
float2 uv,
float4 tintColor,
float cutoff,
float wear,
float dirt,
float scratches,
out float3 Albedo,
out float Alp,
out float AlpClip
)
{

float4 maskSample = SampleTex(t2d, uv);

// 反照率
float4  g_sample  =  ( maskSample.g ).xxxx ;
float4  lerpResult13  =  lerp(  float4( 1, 1, 1, 0 ),  g_sample,   dirt ); // dirt : 0, 没有污渍
Albedo  =  ( lerpResult13  *  tintColor ).rgb ;

// Alpha Clip
float  lerpResult18   =  lerp( 1.0 , maskSample.r,   scratches ); // 划痕
float  lerpResult10   =  lerp( maskSample.a,   maskSample.b,   wear ); // 磨损
Alp = lerpResult18  *  lerpResult10 ;
AlpClip   =  cutoff ;

}



void ClipRGB_float
(
UnityTexture2D t2d,
UnityTexture2D t2d_2,
float2 uv,
float4 tintColor,
float cutoff,
float wear,
float dirt,
float scratches,
out float3 Albedo,
out float Alp,
out float AlpClip
)
{
	float4 baseSample = SampleTex(t2d, uv);
	float4 maskSample = SampleTex(t2d_2, uv);

	// 反照率 (基础色 + 污渍）
	float4  lerpResult13  =  lerp( baseSample,   baseSample *  maskSample.g,   dirt ); 
	Albedo  =  ( lerpResult13  *  tintColor ).rgb ;

	// Alpha Clip
	float lerpResult18  =  lerp( 1.0,  maskSample.r,   scratches ); // 划痕（scratches = 0表示没有划痕，= 1 取混合图中的划痕数据）
	float lerpResult10  =  lerp( maskSample.a,   maskSample.b,   wear ); // 磨损数据（b：磨损，a：无磨损）
	//AlpClip  =  1  -  step(  cutoff,   lerpResult18  *  lerpResult10  );

	Alp = lerpResult18  *  lerpResult10 ;
	AlpClip  =  cutoff ;
}



#endif //带 Alpha 裁剪相关的着色（由 Graphi 着色库工具生成）| 作者：强辰