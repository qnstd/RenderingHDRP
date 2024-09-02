#ifndef NBLENDSHADERGRAPH
#define NBLENDSHADERGRAPH

// 引入法线混合操作库
#include "Graphi-BlendNormal.hlsl"


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


#endif //ShaderGraph NormalBlend 节点处理脚本（由 Graphi 着色库工具生成）| 作者：强辰