#ifndef FURVERTMESH
#define FURVERTMESH


struct VaryingsToPS
{
    VaryingsMeshToPS vmesh;
#ifdef VARYINGS_NEED_PASS
    VaryingsPassToPS vpass;
#endif
};


struct PackedVaryingsToPS
{
    PackedVaryingsMeshToPS vmesh;
#ifdef VARYINGS_NEED_PASS
    PackedVaryingsPassToPS vpass;
#endif
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
#ifdef VARYINGS_NEED_PASS
    output.vpass = PackVaryingsPassToPS(input.vpass);
#endif
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

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
PackedVaryingsToPS VertMeshToLightTransport(AttributesMesh input)
{
    VaryingsToPS output = (VaryingsToPS)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output.vmesh);

    #if defined(HAVE_MESH_MODIFICATION)
        input = ApplyMeshModification(input, _TimeParameters.xyz);
    #endif

    output.vmesh.positionCS = UnityMetaVertexPosition(input.positionOS, input.uv1.xy, input.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);

    #ifdef VARYINGS_NEED_POSITION_WS
        output.vmesh.positionRWS = TransformObjectToWorld(input.positionOS);
    #endif

    #ifdef VARYINGS_NEED_TANGENT_TO_WORLD
        output.vmesh.normalWS = TransformObjectToWorldNormal(input.normalOS);
        output.vmesh.tangentWS = float4(1.0, 0.0, 0.0, 0.0);
    #endif

    #ifdef EDITOR_VISUALIZATION
        float2 vizUV = 0;
        float4 lightCoord = 0;
        UnityEditorVizData(input.positionOS.xyz, input.uv0.xy, input.uv1.xy, input.uv2.xy, vizUV, lightCoord);
    #endif

    #ifdef VARYINGS_NEED_TEXCOORD0
        output.vmesh.texCoord0 = input.uv0;
    #endif
    #ifdef VARYINGS_NEED_TEXCOORD1
    #ifdef EDITOR_VISUALIZATION
        output.vmesh.texCoord1.xy = vizUV.xy;
    #else
        output.vmesh.texCoord1 = input.uv1;
    #endif
    #endif
    #ifdef VARYINGS_NEED_TEXCOORD2
        // texCoord2 = lightCoord
    #ifdef EDITOR_VISUALIZATION
        output.vmesh.texCoord2.xy = lightCoord.xy;
    #else
        output.vmesh.texCoord2 = input.uv2;
    #endif
    #endif
    #ifdef VARYINGS_NEED_TEXCOORD3
    #ifdef EDITOR_VISUALIZATION
        output.vmesh.texCoord3.xy = lightCoord.zw;
        output.vmesh.texCoord3.z = input.uv3.z;
    #else
        output.vmesh.texCoord3 = input.uv3;
    #endif
    #endif
    #ifdef VARYINGS_NEED_COLOR
        output.vmesh.color = input.color;
    #endif

    return PackVaryingsToPS(output);
}
#endif


// 顶点信息转为插值数据，为片元数据输入做准备
VaryingsMeshType VertMesh(AttributesMesh input, float3 worldSpaceOffset)
{
    VaryingsMeshType output;

    #if defined(USE_CUSTOMINTERP_SUBSTRUCT) || defined(HAVE_VFX_MODIFICATION)
        ZERO_INITIALIZE(VaryingsMeshType, output); 
    #endif

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    // 自定义顶点变换处理
    #ifdef HAVE_MESH_MODIFICATION
        input = ApplyMeshModification(input, _TimeParameters.xyz);
    #endif

    // 法线、切线、世界位置及 SV_Postion 数据设置    
    float3 positionRWS = TransformObjectToWorld(input.positionOS) + worldSpaceOffset;
    #ifdef ATTRIBUTES_NEED_NORMAL
        float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    #else
        float3 normalWS = float3(0.0, 0.0, 0.0); 
    #endif

    #ifdef ATTRIBUTES_NEED_TANGENT
        float4 tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
    #endif

    #if defined(HAVE_VERTEX_MODIFICATION)
        ApplyVertexModification(input, normalWS, positionRWS, _TimeParameters.xyz);
    #endif

    #ifdef VARYINGS_NEED_POSITION_WS
        output.positionRWS = positionRWS;
    #endif
    #ifdef VARYINGS_NEED_POSITIONPREDISPLACEMENT_WS
        output.positionPredisplacementRWS = positionRWS;
    #endif

    output.positionCS = TransformWorldToHClip(positionRWS);

    #ifdef VARYINGS_NEED_TANGENT_TO_WORLD
        output.normalWS = normalWS;
        output.tangentWS = tangentWS;
    #endif

    #if !defined(SHADER_API_METAL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_FULL_SCREEN_DEBUG)
        if (_DebugFullScreenMode == FULLSCREENDEBUGMODE_VERTEX_DENSITY)
            IncrementVertexDensityCounter(output.positionCS);
    #endif

    // uv
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
    #if defined(VARYINGS_NEED_COLOR) || defined(VARYINGS_DS_NEED_COLOR)
        output.color = input.color;
    #endif

    return output;
}


VaryingsMeshType VertMesh(AttributesMesh input){ return VertMesh(input, 0.0f); }


#endif //（由 Graphi 着色库工具生成）| 作者：强辰