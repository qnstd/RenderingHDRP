#ifndef GRAPHI_TRANSFORMATION
#define GRAPHI_TRANSFORMATION

// UV 坐标旋转
// rot      : 旋转的角度
// pivot    : 旋转的中心点
// uv       : 原始 uv 值
void UVRot(float rot, float2 pivot, inout float2 uv)
{
    float r = rot * 3.1415926 / 180;
    uv -= pivot;  //减去中心位置，相当于以中心位置旋转
    uv = mul
    (
        float3(uv, 1),
        float3x3
        (//3x3旋转矩阵
            cos(r), -sin(r), 0,
            sin(r), cos(r), 0,
            0, 0, 1
            )
    ).xy;
    uv += pivot;
}


// UV 坐标旋转（旋转的中心点为（0.5,0.5））
// r    : 旋转的弧度
// uv   : 原始 uv 值
float2 UVRot2( float r, float2 uv )
{
    uv -= 0.5;
	float s = sin ( r );
	float c = cos ( r );
	uv = mul ( uv, float2x2( c, -s, s, c) );
	uv += 0.5;
	return uv;
}



#endif //变换相关操作（由 Graphi 着色库工具生成）| 作者：强辰
