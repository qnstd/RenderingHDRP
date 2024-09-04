#ifndef TEX
#define TEX

#include "Normal.hlsl"

// 常规纹理采样
float4 SampleTex(UnityTexture2D t2d, float2 uvs)
{
	return SAMPLE_TEXTURE2D(t2d.tex, t2d.samplerstate, t2d.GetTransformedUV(uvs));
}



// 三向采样
void TexSampleTriplanar_float
(
//input
//tex		: 纹理（纹理不允许设置 TillingAndOffset 的值。应永远为（1,1,0,0））
//pos		: 采样坐标（模型空间）
//n			: 法线（世界空间）
//tile		: 瓦片（对采样坐标的放大缩小）
//blends	: 混合值
UnityTexture2D t2d, float3 pos, float3 n, float tile, float blends,
//out
out float4 Out
)
{
	// 法线计算
	float3 unnormalizedNormal = n;
	float renormFactor = 1.0 / length(unnormalizedNormal);
	float3 N = renormFactor * n;
	float3 Ble = SafePositivePow_float( N, min(blends, floor(log2(Min_float())/log2(1/sqrt(3)))) );
	Ble /= dot(Ble, 1.0);

	// UV & 采样
	float3 uv = pos * tile;
	float4 X = SampleTex(t2d, uv.zy);
	float4 Y = SampleTex(t2d, uv.xz);
	float4 Z = SampleTex(t2d, uv.xy);

	// 设置权重
	float4 blendXYZ = X * Ble.x + Y * Ble.y + Z * Ble.z;

	// 输出
	Out = float4(blendXYZ.x, blendXYZ.y, blendXYZ.z, 1.0);
}



// 三向采样（法线）
void NormalTexSampleTriplanar_float
(
// input
// tex		: 纹理（纹理不允许设置 TillingAndOffset 的值。应永远为（1,1,0,0））
// pos		: 采样坐标（模型空间）
// n		: 法线（世界空间）
// t		: 切线（世界空间）
// tile		: 瓦片（对采样坐标的放大缩小）
// blends	: 混合值
// force	: 法线强度
UnityTexture2D t2d, 
float3 pos, 
float3 n,
float3 t,
float tile, 
float blends,
float force,
// out
out float3 N
)
{
	// 重新计算归一化因子
	float3 unnormalizedNormal = n;
	const float renorFactor = 1.0 / length(unnormalizedNormal);

	// 重新计算副法线
	//float crosssign = (t.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale(); // 如果开启双面渲染，切线及副法线不允许进行翻转
	float3 bitangent = /*crosssign **/ cross(n.xyz , t.xyz);


	// 获得真实的法线、切线、副法线向量
	float3 normalWS = renorFactor * n.xyz;
	float3 tangentWS = renorFactor * t.xyz;
	float3 bitangentWS = renorFactor * bitangent.xyz;
	float3x3 tangentTransform = float3x3(tangentWS, bitangentWS, normalWS); // 创建世界空间到切线空间的变换矩阵

	// 采样
	float3 uv = pos * tile;
	float3 Nx = UnpackNormal(SampleTex(t2d, uv.zy));
	float3 Ny = UnpackNormal(SampleTex(t2d, uv.xz));
	float3 Nz = UnpackNormal(SampleTex(t2d, uv.xy));
	// 设置强度
	Nx = NormalForce(Nx, force);
	Ny = NormalForce(Ny, force);
	Nz = NormalForce(Nz, force);

	// 根据顶点的世界法线对三次采样结果做权重分析
	Nx = float3(Nx.xy + normalWS.zy, abs(Nx.z) * normalWS.x);
	Ny = float3(Ny.xy + normalWS.xz, abs(Ny.z) * normalWS.y);
	Nz = float3(Nz.xy + normalWS.xy, abs(Nz.z) * normalWS.z);

	// 计算权重
	float3 ble = SafePositivePow_float(normalWS, min(blends, floor(log2(Min_float())/log2(1/sqrt(3)))) );
	ble /= (ble.x + ble.y + ble.z).xxx;

	// 计算最终法线
	N = float3(Nx.zyx * ble.x + Ny.xzy * ble.y + Nz.xyz * ble.z);
	N = TransformWorldToTangent(N, tangentTransform, true); // 将法线从世界空间转到切线空间
}




#endif //纹理相关计算（由 Graphi 着色库工具生成）| 作者：强辰