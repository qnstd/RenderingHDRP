#ifndef VEC
#define VEC

#include "Transformation.hlsl"


// 获取绝对世界空间下的视角向量
// posWS ： 顶点的绝对世界空间位置
float3 GetAbsoluteViewWS(float3 posWS)
{
    return _WorldSpaceCameraPos.xyz - posWS;
}


// 获取绝对世界位置
// posRWS : 相对摄像机的世界空间位置
float3 GetAbsolutePosWS(float3 posRWS)
{
    return GetAbsolutePositionWS(posRWS);   
}


// BoxProjector 反射向量优化
// reflectDir   : 反射方向
// worldPos     : 绝对世界空间坐标
// center       : BoxProjected 中心位置（xyz：位置，w的值若为1，则说明以Box形式计算；不为1，则直接返回反射向量）
// boxMin       : BoxProjected 左下角位置
// boxMax       : BoxProjected 右上角位置
float3 BoxProjectedDirection(float3 reflectDir, float3 worldPos, float4 center, float3 boxMin, float3 boxMax)
{
    UNITY_BRANCH
    if (center.w > 0.0) // w = 1.0 说明开启了boxprojector模式。
    {
        float3 nrdir = normalize(reflectDir);

        #if 1
            float3 rbmax = (boxMax.xyz - worldPos) / nrdir;
            float3 rbmin = (boxMin.xyz - worldPos) / nrdir;
            float3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;

        #else // 优化版本
            float3 rbmax = (boxMax.xyz - worldPos);
            float3 rbmin = (boxMin.xyz - worldPos);
            float3 select = step (float3(0,0,0), nrdir);
            float3 rbminmax = lerp (rbmax, rbmin, select);
            rbminmax /= nrdir;

        #endif

        float fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);
        worldPos -= center.xyz;
        reflectDir = worldPos + nrdir * fa;
    }
    return reflectDir;
}



// 计算反射向量（世界空间）
// gNormalWS : 顶点的世界空间法线
// gTangentWS : 顶点的世界空间切线
// dir : 方向
// nTS : 法线（切线空间）
float3 ReflectDirectionWS(float3 gNormalWS, float3 gTangentWS, float3 dir, float3 nTS)
{
    // 方向
    if(!IsPerspectiveProjection())
    {// 非透视矩阵
        dir = GetViewForwardDir() * dot(dir, GetViewForwardDir());
    }

    // 法线
    float3x3 tangentToWorldMatrix = GetTangentToWorldMatrix(gNormalWS, float4(gTangentWS, 1.0));
    float3 nWS = TransformTangentToWorld(nTS.xyz, tangentToWorldMatrix, true);

    // 反射方向
    return reflect(-dir, nWS);
}



// 计算视角的反射向量（世界空间）
// gNormalWS : 顶点的世界空间法线
// gTangentWS : 顶点的世界空间切线
// gPosRWS : 顶点的世界空间位置（相对摄像机）
// nTS : 法线（切线空间）
float3 ReflectDirectionOfViewWS(float3 gNormalWS, float3 gTangentWS, float3 gPosRWS, float3 nTS)
{
    float3 viewWS = GetAbsoluteViewWS(GetAbsolutePositionWS(gPosRWS)); // 绝对世界空间的视角向量
    return ReflectDirectionWS(gNormalWS, gTangentWS, viewWS, nTS);
}

#endif //向量计算（由 Graphi 着色库工具生成）| 作者：强辰