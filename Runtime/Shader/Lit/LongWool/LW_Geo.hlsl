#ifndef LW_GEO
#define LW_GEO


inline float Rand(float2 seed)
{
    return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453);
}
inline float3 Rand3(float2 seed)
{
    return 2.0 * (float3(Rand(seed * 1), Rand(seed * 2), Rand(seed * 3)) - 0.5);
}



void AppendFinVertex
(
    inout TriangleStream<PackedVaryingsType> stream, 
    float2 uv, 
    float2 lightmapUV, 
    float3 posOS, 
    float3 normalOS, 
    float2 finUv,
    float3 finSideDirWS
)
{
    GeoMesh data = (GeoMesh)0;

    // 位置、法线
    data.positionOS = posOS;
    data.normalOS = normalOS;

    // 毛发参数
    data.finUV = (SHADERPASS == SHADERPASS_SHADOWS) ? float2(-1.0, -1.0) : finUv;
    data.finTangentWS = float3(SafeNormalize(cross(TransformObjectToWorldNormal(normalOS), finSideDirWS)));

    // uv
#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
data.uv0.xy = uv;
data.uv1.xy = lightmapUV;

#elif SHADERPASS == SHADERPASS_SHADOWS

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
data.uv0.xy = uv;

#else
data.uv0.xy = uv;
data.uv1.xy = lightmapUV;

#endif

    // 添加新的顶点
    stream.Append(PackVaryMesh(data));
}



/*
    添加额外生成的毛发顶点数据
*/
void AppendFinVertices
( 
    inout TriangleStream<PackedVaryingsType> stream, 
    TesselationMesh input0, TesselationMesh input1, TesselationMesh input2
)
{
    // 位置
    float3 posOS0 = input0.positionOS.xyz;
    float3 lineOS01 = input1.positionOS.xyz - posOS0;
    float3 lineOS02 = input2.positionOS.xyz - posOS0;
    float3 posOS3 = posOS0 + (lineOS01 + lineOS02) / 2;

    float2 tiling = float2(_TillingAndOffset.x, _TillingAndOffset.y);
    float2 offs = float2(_TillingAndOffset.z, _TillingAndOffset.w);
    #define transform_tex(uv) uv * tiling + offs

    // UV
    #if SHADERPASS != SHADERPASS_SHADOWS
        float2 uv0 = transform_tex(input0.uv0);
        float2 uv12 = (transform_tex(input1.uv0) + transform_tex(input2.uv0)) / 2;
        float uvOffset = length(uv0);
        float uvXScale = length(uv0 - uv12) * _Density;

        #if SHADERPASS != SHADERPASS_DEPTH_ONLY
            float2 lightmapUV0 = input0.uv1;
            float2 lightmapUV12 = (input1.uv1 + input2.uv1) / 2;
        #else
            float2 lightmapUV0 = 0;
            float2 lightmapUV12 = 0;
        #endif
    #else
        float2 uv0 = float2(0,0);
        float2 uv12 = float2(0,0);
        float uvOffset = 0;
        float uvXScale = 0;
        float2 lightmapUV0 = 0;
        float2 lightmapUV12 = 0;
    #endif
    
    // 法线
    float3 normalOS0 = input0.normalOS;
    float3 dir = normalOS0;
    dir += Rand3(input0.positionOS.xy) * _RandomDirection;
    dir = normalize(dir);
    float3 dirWS = TransformObjectToWorldNormal(dir);

    // 毛发相关的基本参数
    float3 posWS = TransformObjectToWorld(posOS0);
    float finStep = _Length / _NearSurface;
    float3 windMoveWS = _WindAxisSpeed.xyz * sin(_Time.w * _WindAxisWeight.xyz + posWS * _WindPhase);
    float3 baseMoveWS = _BaseOffset.xyz;
    float3 finSideDirOS = normalize(posOS3 - posOS0);
    float3 finSideDirWS = TransformObjectToWorldDir(finSideDirOS);

    [unroll]
    for (int j = 0; j < 2; ++j)
    {
        float3 posBeginOS = posOS0;
        float3 posEndOS = posOS3;
        float uvX1 = uvOffset;
        float uvX2 = uvOffset + uvXScale;

        [loop] 
        for (int i = 0; i <= _NearSurface; ++i)
        {
            // 根据上边计算的法线方向，计算发根到发尖儿的摇摆程度、方向
            float factor = (float) i / _NearSurface;
            float swingFactor = pow(abs(factor), _SwingPow);
            float3 moveWS = SafeNormalize(dirWS + (baseMoveWS + windMoveWS) * swingFactor) * finStep;
            float3 moveOS = TransformWorldToObjectDir(moveWS, false); // 将摇摆方向从世界空间转为模型空间（这里不做归一化，因为后续要根据此值计算最终的目标位置）
            
            posBeginOS += moveOS;
            posEndOS += moveOS;
            float3 dirOS03 = normalize(posEndOS - posBeginOS);
            float3 faceNormalOS = normalize(cross(dirOS03, moveOS));
            if (j == 0)
            {
                float3 nOS = normalize(lerp(normalOS0, faceNormalOS, _FaceNormalFactor));
                AppendFinVertex(stream, uv0, lightmapUV0, posBeginOS, nOS, float2(uvX1, factor), finSideDirWS);
                AppendFinVertex(stream, uv12, lightmapUV12, posEndOS, nOS, float2(uvX2, factor), finSideDirWS);
            }
            else
            {
                faceNormalOS *= -1.0;
                float3 nOS = normalize(lerp(normalOS0, faceNormalOS, _FaceNormalFactor));
                AppendFinVertex(stream, uv12, lightmapUV12, posEndOS, nOS, float2(uvX2, factor), finSideDirWS);
                AppendFinVertex(stream, uv0, lightmapUV0, posBeginOS, nOS, float2(uvX1, factor), finSideDirWS);
            }
        }
        stream.RestartStrip();
    }
}



/*
    追加源顶点数据
*/
void AppendOriginVertices(triangle TesselationMesh input[3], inout TriangleStream<PackedVaryingsType> stream)
{
    for (int i = 0; i < 3; ++i)
    {
        GeoMesh data = (GeoMesh)0;

        data.positionOS = input[i].positionOS;
        data.normalOS = input[i].normalOS;
   
        data.finUV = float2(-1.0, -1.0);
        data.finTangentWS = 0;

    #if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
    data.uv0 = input[i].uv0;
    data.uv1 = input[i].uv1;
    data.uv2 = input[i].uv2;
    data.uv3 = input[i].uv3;

    #elif SHADERPASS == SHADERPASS_SHADOWS
    data.tangentOS = input[i].tangentOS;

    #elif SHADERPASS == SHADERPASS_DEPTH_ONLY 
    data.tangentOS = input[i].tangentOS;
    data.uv0 = input[i].uv0;

    #else
    data.tangentOS = input[i].tangentOS;
    data.uv0 = input[i].uv0;
    data.uv1 = input[i].uv1;

    #endif

        stream.Append(PackVaryMesh(data));

    }
    stream.RestartStrip();
}


/*
    几何着色程序入口
*/
[maxvertexcount(33)]
void Geom(triangle TesselationMesh input[3], inout TriangleStream<PackedVaryingsType> stream)
{
#ifdef _DRAW_ORIGIN_MESH
    AppendOriginVertices(input, stream);
#endif

// ///////////////////////////////////////////////
// 计算面朝方向的区域、角度，用于毛发的生成与取消

    // 计算输入面片的归一化法线
    float3 lineOS01 = (input[1].positionOS - input[0].positionOS).xyz;
    float3 lineOS02 = (input[2].positionOS - input[0].positionOS).xyz;
    float3 normalOS = normalize(cross(lineOS01, lineOS02));
    // 计算面片中心位置、摄像机到中心位置的向量
    float3 centerOS = (input[0].positionOS + input[1].positionOS + input[2].positionOS).xyz / 3;
    float3 cameraPosOS = TransformWorldToObject( GetCameraPositionWS() );
    float3 viewDirOS = centerOS - cameraPosOS;
    // 判断视角（面朝正视的区域、角度）
    float VdotN = dot(normalize(viewDirOS), normalize(normalOS));
    VdotN = abs(VdotN);
    VdotN = clamp(VdotN, 0, 1);
    if (VdotN > _FaceViewThreshold) return;

// END
// ///////////////////////////////////////////////

    // 计算并添加顶点
    AppendFinVertices(stream, input[0], input[1], input[2]);
}



#endif //几何着色操作，生成毛发 | 作者：强辰