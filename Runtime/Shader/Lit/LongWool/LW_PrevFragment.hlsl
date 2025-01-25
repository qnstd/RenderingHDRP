#ifndef LW_PREVFRAGMENT
#define LW_PREVFRAGMENT


#include "LW_VeryMeshOperate.hlsl"


/*
    顶点着色
*/
TesselationMesh Vert(AttributesMesh inputMesh)
{
    return CopyAttributesMesh(inputMesh);
}


/*
    曲面细分着色
*/
#include "LW_Tessellation.hlsl"


/*
    几何着色
*/
#include "LW_Geo.hlsl"



#endif //片元着色阶段之前的相关操作 | 作者：强辰