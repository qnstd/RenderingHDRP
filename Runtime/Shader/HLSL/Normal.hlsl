#ifndef GRAPHI_NORMAL
#define GRAPHI_NORMAL

// ////////////////////////////////////////////////////////////
// ******
// 以下所有方法参数法线必须是 Unpack 解包并归一化后的法线


// 线性混合
float3 BlendNormal_Linear(float3 n1, float3 n2)
{
	float3 r = (n1 + n2) * 2 - 2;
	return normalize(r);
}



// Overlay混合（越亮或越暗的原图在合成后的位置也是越亮越暗，而灰度区域则使用混合图的颜色）
float3 BlendNormal_Overlay(float3 n1, float3 n2)
{
	n1 = n1 * 4 -2;
	float3 a = n1 >= 0 ? -1 : 1;
	float3 b = n1 >= 0 ? 1 : 0;
	n1 = 2 * a + n1;
	n2 = n2 * a + b;
	float3 r = n1 * n2 - a;
	return normalize(r);
}



// UDN混合（Unreal Developer Network）
float3 BlendNormal_UDN(float3 n1, float3 n2)
{
	float3 c = float3(2, 1, 0);
	float3 r= n2 * c.yyz + n1.xyz;
	r = r * c.xxx - c.xxy;
	return normalize(r);
}



// RNM混合（Reoriented Normal Mapping）
float3 BlendNormal_RNM(float3 n1, float3 n2)
{
	float3 t = n1.xyz * float3(2, 2, 2) + float3(-1, -1, 0);
	float3 u = n2.xyz * float3(-2, -2, 2) + float3(1, 1, -1);
	float3 r = t * dot(t, u) - u * t.z;
	return normalize(r);
}


// RNM混合（Unity 内置的混合操作）
float3 BlendNormal_RNM2(real3 n1, real3 n2)
{
	real3 t = n1.xyz + real3(0.0, 0.0, 1.0);
    real3 u = n2.xyz * real3(-1.0, -1.0, 1.0);
    real3 r = (t / t.z) * dot(t, u) - u;
    return r;
}



/*
	法线混合
*/
void BlendNormalDeal_float
(
// Input
float3 n1,
float3 n2,
float blendtype,
// Output
out float3 blendnormal
)
{
	if(blendtype == 0)
		blendnormal = BlendNormal_Linear(n1,  n2);

	else if(blendtype == 1)
		blendnormal = BlendNormal_Overlay(n1,  n2);

	else if(blendtype == 2)
		blendnormal = BlendNormal_UDN(n1,  n2);

	else if(blendtype == 3)
		blendnormal = BlendNormal_RNM(n1,  n2);

	else if(blendtype == 4)
		blendnormal = BlendNormal_RNM2(n1,  n2);

	else
		blendnormal = n1; // 不进行混合操作
}

// ******
// ////////////////////////////////////////////////////////////



/*
	法线强度
*/
float3 NormalForce(float3 n, float force)
{
	return float3(n.rg * force, lerp(1.0, n.b, saturate(force)));
}


#endif //法线相关计算（由 Graphi 着色库工具生成）| 作者：强辰