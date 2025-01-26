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



// 3d旋转
// In : 要旋转的向量或者点
// Axis : 轴向
// Radians : 弧度
float3 RotateAxis(float3 In, float3 Axis, float Radians)
{
    float s = sin(Radians);
    float c = cos(Radians);
    float one_minus_c = 1.0 - c;

    Axis = normalize(Axis);

    float3x3 rot_mat = { 
                            one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                            one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                            one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                        };

    return mul(rot_mat,  In);
}



// 欧拉角（弧度）转四元数
// radian : 弧度
float4 RadiansToQuaternion(float3 radian)
{
    float3 r = radian;
    r *= 0.5;

    // 前缀c = cos， 前缀s = sin
    float cyaw = cos(r.z); // 绕z
    float syaw = sin(r.z);
    float cpitch = cos(r.y); // 绕y
    float spitch = sin(r.y);
    float croll = cos(r.x); // 绕x
    float sroll = sin(r.x);

    // 计算四元数4个值
    float x = cyaw * cpitch * sroll - syaw * spitch * croll;
    float y = syaw * cpitch * sroll + cyaw * spitch * croll;
    float z = syaw * cpitch * croll - cyaw * spitch * sroll;
    float w = cyaw * cpitch * croll + syaw * spitch * sroll;
                
    return float4(x,y,z,w);
}



// 欧拉角转四元数
// euler : 角度
float4 EulerToQuaternion(float3 euler)
{
    return RadiansToQuaternion(radians(euler));
}



// 四元数转矩阵
// q : 四元数
float4x4 QuaternionToMatrix(float4 q)
{
    float num = q.x * 2;
    float num2 = q.y * 2;
    float num3 = q.z * 2;
    float num4 = q.x * num;
    float num5 = q.y * num2;
    float num6 = q.z * num3;
    float num7 = q.x * num2;
    float num8 = q.x * num3;
    float num9 = q.y * num3;
    float num10 = q.w * num;
    float num11 = q.w * num2;
    float num12 = q.w * num3;

    /*
         创建矩阵，并计算16个值
         [
            M11, M12, M13, M14,
            M21, M22, M23, M24,
            M31, M32, M33, M34,
            M41, M42, M43, M44
         ]
    */
    float4x4 m = float4x4
    (
        1 - (num5 + num6),      num7 - num12,               num8 + num11,           0,
        num7 + num12,           1 - (num4 + num6),          num9 - num10,           0,
        num8 - num11,           num9 + num10,               1 - (num4 + num5),      0,
        0,                      0,                          0,                      1
    );

    return m;
}




// 四元数相乘
// q : 四元数
// p : 向量或点
float3 QuaternionMultiply(float4 q, float3 p)
{
    float num = q.x * 2;
    float num2 = q.y * 2;
    float num3 = q.z * 2;
    float num4 = q.x * num;
    float num5 = q.y * num2;
    float num6 = q.z * num3;
    float num7 = q.x * num2;
    float num8 = q.x * num3;
    float num9 = q.y * num3;
    float num10 = q.w * num;
    float num11 = q.w * num2;
    float num12 = q.w * num3;

    float3 result = float3
    (
        (1 - (num5 + num6)) * p.x + (num7 - num12) * p.y + (num8 + num11) * p.z,
        (num7 + num12) * p.x + (1 - (num4 + num6)) * p.y + (num9 - num10) * p.z,
        (num8 - num11) * p.x + (num9 + num10) * p.y + (1 - (num4 + num5)) * p.z
    );
    
    return result;
}




// 世界矩阵背面的缩放因子
float GetNegativeScale()
{
    return unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0;
}


// 计算切线空间转世界空间矩阵
// geomNormalWS : 顶点数据中的法线（世界空间）
// geomTangentWS : 顶点数据中的切线（世界空间）
float3x3 GetTangentToWorldMatrix(float3 geomNormalWS, float4 geomTangentWS)
{
    float3 unnormalizedNormalWS = geomNormalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);

    // 双面渲染中支持翻转，这里需要确保切线和切线不会被翻转
    float crossSign = (geomTangentWS.w > 0.0 ? 1.0 : -1.0) * GetNegativeScale();
    float3 bitang = crossSign * cross(geomNormalWS.xyz, geomTangentWS.xyz);

    float3 WorldSpaceNormal = renormFactor * geomNormalWS.xyz;
    float3 WorldSpaceTangent = renormFactor * geomTangentWS.xyz;
    float3 WorldSpaceBiTangent = renormFactor * bitang;

    return float3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
}


#endif //变换相关操作（由 Graphi 着色库工具生成）| 作者：强辰