#ifndef FURGEOMETRY
#define FURGEOMETRY

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/MetaPass.hlsl"
#endif
//#include "FurMotionVectorVertMesh.hlsl"
#include "FurVertMesh.hlsl"


/*
    顶点着色程序
*/
CopyedAttributesMesh Vert(AttributesMesh input)
{// 不做任何处理，直接将输入结构拷贝并输出。具体操作交由几何程序。
    return CopyAttributesMesh(input);
}



// ////////////////////////////////////////////////////
// 几何着色程序


// 构建绒毛顶点
float3 BuildFurVertices(AttributesMesh input, int index)
{
    float3 positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);
    float3 normalOS = input.normalOS;
    float3 normalWS = TransformObjectToWorldNormal(normalOS);

    float offsetFactor = pow(abs((float)index / _Length), _WindForce); // 偏移因子（最下层是不受风力影响，越往上的层受影响越大）
    // 风的偏移影响
    // 1. Wind AxisWeight 用于对风的每个轴向增加权重，使风在不同轴向的风力偏移不一样，这样看起来会更加饱满一些。
    // 2. 除此之外，还增加了原始顶点位置作为 sin 函数的操作因子，其主要目的是让风在每个轴向上的偏移是不规律的（每个顶点摆放的位置本身就是不规则的，将不规则的数据加到规则且固定的数据上时，结果也是不规则的），
    // 这样 sin 函数计算后的值也是不规律的，表现出凌乱的随风飘动效果
    float3 windoffset = offsetFactor * _WindOffset.xyz * sin(_Time.w * _WindAxisWeight.xyz + positionOS * _WindDisturbance); 
    float3 baseoffset = offsetFactor * _BaseOffset.xyz; // 基础偏移

    float3 dir = normalize(normalWS + baseoffset + windoffset);
    float3 posWS = positionWS + dir * (_Step * index);

    return TransformWorldToObject(posWS);
}


void AppendVertexs(inout TriangleStream<PackedVaryingsType> stream, AttributesMesh input, int index)
{
    input.positionOS.xyz = BuildFurVertices(input, index);
    input.uv3.z = (float)index / _Length; // layer

    // 编译打包顶点数据，用于传送给片元着色器的输入参数
    #if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
        stream.Append( VertMeshToLightTransport(input) );

    #else
        VaryingsType varyingsType = (VaryingsType)0;
        varyingsType.vmesh = VertMesh(input);
        PackedVaryingsType packed = PackVaryingsType(varyingsType);
        stream.Append( packed );

    #endif
}


// 顶点输出不能超过1024，否则会报 error: X8000 错误。
// 需要注意的是，当顶点中包含的数据类型及数量越多，几何渲染程序中创建的新顶点数就会越少。
[maxvertexcount(30)]  
void Geom(triangle CopyedAttributesMesh input[3], inout TriangleStream<PackedVaryingsType> stream)
{
    // 输入类型为三角形，输出为三角数据流的情况下
    for(int i=0; i<_Length; i++)
    {
        for(int j=0; j<3; j++)
        {
            AppendVertexs(stream, RestoreAttributesMesh(input[j]), i);
        }
        stream.RestartStrip();
    }
}


// 结束
// ///////////////////////////////////////////////////

#endif //绒毛几何变换（由 Graphi 着色库工具生成）| 作者：强辰