#ifndef LW_VERYMESHOPERATE
#define LW_VERYMESHOPERATE


struct VaryingsToPS
{
    VaryingsMeshToPS vmesh;
};

struct PackedVaryingsToPS
{
    PackedVaryingsMeshToPS vmesh;
    UNITY_VERTEX_OUTPUT_STEREO

#if defined(PLATFORM_SUPPORTS_PRIMITIVE_ID_IN_PIXEL_SHADER) && SHADER_STAGE_FRAGMENT
#if (defined(VARYINGS_NEED_PRIMITIVEID) || (SHADERPASS == SHADERPASS_FULL_SCREEN_DEBUG))
    uint primitiveID : SV_PrimitiveID;
#endif
#endif

#if defined(VARYINGS_NEED_CULLFACE) && SHADER_STAGE_FRAGMENT
    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryingsToPS PackVaryingsToPS(VaryingsToPS input)
{
    PackedVaryingsToPS output;
    output.vmesh = PackVaryingsMeshToPS(input.vmesh);

    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    return output;
}

FragInputs UnpackVaryingsToFragInputs(PackedVaryingsToPS packedInput)
{
    FragInputs input = UnpackVaryingsMeshToFragInputs(packedInput.vmesh);

#if defined(PLATFORM_SUPPORTS_PRIMITIVE_ID_IN_PIXEL_SHADER) && SHADER_STAGE_FRAGMENT
#if (defined(VARYINGS_NEED_PRIMITIVEID) || (SHADERPASS == SHADERPASS_FULL_SCREEN_DEBUG))
    input.primitiveID = packedInput.primitiveID;
#endif
#endif

#if defined(VARYINGS_NEED_CULLFACE) && SHADER_STAGE_FRAGMENT
    input.isFrontFace = IS_FRONT_VFACE(packedInput.cullFace, true, false);
#endif

    return input;
}


#define VaryingsType VaryingsToPS
#define VaryingsMeshType VaryingsMeshToPS
#define PackedVaryingsType PackedVaryingsToPS
#define PackVaryingsType PackVaryingsToPS



VaryingsMeshType VaryMesh(GeoMesh input, float3 worldSpaceOffset)
{
    VaryingsMeshType output = (VaryingsMeshType)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    float3 positionRWS = TransformObjectToWorld(input.positionOS) + worldSpaceOffset;
#ifdef ATTRIBUTES_NEED_NORMAL
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
#else
    float3 normalWS = float3(0.0, 0.0, 0.0); 
#endif

#ifdef ATTRIBUTES_NEED_TANGENT
    float4 tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
#endif

    
    // 位置
#ifdef VARYINGS_NEED_POSITION_WS
    output.positionRWS = positionRWS;
#endif
#ifdef VARYINGS_NEED_POSITIONPREDISPLACEMENT_WS
    output.positionPredisplacementRWS = positionRWS;
#endif
    output.positionCS = TransformWorldToHClip(positionRWS);

    // 法线、切线
#ifdef VARYINGS_NEED_TANGENT_TO_WORLD
    output.normalWS = normalWS;
    output.tangentWS = tangentWS;
#endif

    // UV
#if defined(VARYINGS_NEED_TEXCOORD0) || defined(VARYINGS_DS_NEED_TEXCOORD0)
    output.texCoord0 = input.uv0;
#endif
#if defined(VARYINGS_NEED_TEXCOORD1) || defined(VARYINGS_DS_NEED_TEXCOORD1)
    output.texCoord1 = input.uv1;
#endif
#if defined(VARYINGS_NEED_TEXCOORD2) || defined(VARYINGS_DS_NEED_TEXCOORD2)
    output.texCoord2 = input.uv2;
#endif
#if defined(VARYINGS_NEED_TEXCOORD3) || defined(VARYINGS_DS_NEED_TEXCOORD3)
    output.texCoord3 = input.uv3;
#endif

    // 顶点颜色
#if defined(VARYINGS_NEED_COLOR) || defined(VARYINGS_DS_NEED_COLOR)
    output.color = input.color;
#endif

    
    // 毛发数据
    output.finUV = input.finUV;
    output.finTangentWS = input.finTangentWS;

    return output;
}



#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
VaryingsMeshType VaryMeshLightTransport(GeoMesh inputMesh)
{
    VaryingsMeshType output = (VaryingsMeshType)0;
    UNITY_SETUP_INSTANCE_ID(inputMesh);
    UNITY_TRANSFER_INSTANCE_ID(inputMesh, output);

    output.positionCS = UnityMetaVertexPosition(inputMesh.positionOS, inputMesh.uv1.xy, inputMesh.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);

#ifdef VARYINGS_NEED_POSITION_WS
    output.positionRWS = TransformObjectToWorld(inputMesh.positionOS);
#endif

#ifdef VARYINGS_NEED_TANGENT_TO_WORLD
    output.normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
    output.tangentWS = float4(1.0, 0.0, 0.0, 0.0);
#endif

#ifdef EDITOR_VISUALIZATION
    float2 vizUV = 0;
    float4 lightCoord = 0;
    UnityEditorVizData(inputMesh.positionOS.xyz, inputMesh.uv0.xy, inputMesh.uv1.xy, inputMesh.uv2.xy, vizUV, lightCoord);
#endif

#ifdef VARYINGS_NEED_TEXCOORD0
    output.texCoord0 = inputMesh.uv0;
#endif
#ifdef VARYINGS_NEED_TEXCOORD1
#ifdef EDITOR_VISUALIZATION
    output.texCoord1.xy = vizUV.xy;
#else
    output.texCoord1 = inputMesh.uv1;
#endif
#endif
#ifdef VARYINGS_NEED_TEXCOORD2
#ifdef EDITOR_VISUALIZATION
    output.texCoord2.xy = lightCoord.xy;
#else
    output.texCoord2 = inputMesh.uv2;
#endif
#endif
#ifdef VARYINGS_NEED_TEXCOORD3
#ifdef EDITOR_VISUALIZATION
    output.texCoord3.xy = lightCoord.zw;
#else
    output.texCoord3 = inputMesh.uv3;
#endif
#endif
#ifdef VARYINGS_NEED_COLOR
    output.color = inputMesh.color;
#endif

    // 毛发数据
    output.finUV = inputMesh.finUV;
    output.finTangentWS = inputMesh.finTangentWS;

    return output;
}
#endif




/*
    将数据打包，为之后送入片元着色做准备
*/
PackedVaryingsType PackVaryMesh(GeoMesh input)
{
    VaryingsType varyingsType = (VaryingsType)0;

    #if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
        varyingsType.vmesh = VaryMeshLightTransport(input);
    #else
        varyingsType.vmesh = VaryMesh(input, 0.0f);
    #endif

    return PackVaryingsType(varyingsType);
}


#endif //网格顶点数据经过曲面细分、几何着色阶段之后，即将送入片元着色阶段前的相关处理 | 作者：强辰