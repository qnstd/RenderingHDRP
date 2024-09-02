#ifndef GRAPHI_LITSURFACEANDBUILTIN_FORWARD
#define GRAPHI_LITSURFACEANDBUILTIN_FORWARD



/* *********************************************
    解压缩从顶点着色器打包输出的数据结构
* *********************************************/
FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
{
    UNITY_SETUP_INSTANCE_ID(input);
#if defined(HAVE_VFX_MODIFICATION) && defined(UNITY_INSTANCING_ENABLED)
    unity_InstanceID = input.instanceID;
#endif
    VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
    return BuildFragInputs(unpacked);
}




/* *****************************************
    构建 SurfaceData 数据
* *****************************************/
void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
{
    ZERO_INITIALIZE(SurfaceData, surfaceData);
        
    surfaceData.specularOcclusion = 1.0;
        
    surfaceData.baseColor =                 surfaceDescription.BaseColor;
    surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
    surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
    surfaceData.metallic =                  surfaceDescription.Metallic;
                
    //SSR 反射
    #if defined(_REFRACTION_PLANE) || defined(_REFRACTION_SPHERE) || defined(_REFRACTION_THIN)
        if (_EnableSSRefraction)
        {
            surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
            surfaceDescription.Alpha = 1.0;
        }
        else
        {
            surfaceData.ior = 1.0;
            surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
            surfaceData.atDistance = 1.0;
            surfaceData.transmittanceMask = 0.0;
            surfaceDescription.Alpha = 1.0;
        }
    #else
        surfaceData.ior = 1.0;
        surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
        surfaceData.atDistance = 1.0;
        surfaceData.transmittanceMask = 0.0;
    #endif
                
    // 材质类型（标准/高光等）
    surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
    #ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
    #endif
        
    #ifdef _MATERIAL_FEATURE_TRANSMISSION
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
    #endif
        
    #ifdef _MATERIAL_FEATURE_ANISOTROPY
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
        surfaceData.normalWS = float3(0, 1, 0);
    #endif
        
    #ifdef _MATERIAL_FEATURE_IRIDESCENCE
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
    #endif
        
    #ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
    #endif
        
    #ifdef _MATERIAL_FEATURE_CLEAR_COAT
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
    #endif
                
    #if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
        surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
    #endif

    // 根据双边计算法线
    float3 doubleSidedConstants = GetDoubleSidedConstants();
    GetNormalWS(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS, doubleSidedConstants);
    surfaceData.geomNormalWS = fragInputs.tangentToWorld[2]; //顶点的世界法线
    surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz); //切线
                
    // 贴花
    #if HAVE_DECALS
        if (_EnableDecals)
        {
            float alpha = 1.0;
            alpha = surfaceDescription.Alpha;
            DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, fragInputs, alpha);
            ApplyDecalToSurfaceData(decalSurfaceData, fragInputs.tangentToWorld[2], surfaceData);
        }
    #endif
        
    bentNormalWS = surfaceData.normalWS;
    surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
    #ifdef DEBUG_DISPLAY
        if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
        {
            surfaceData.metallic = 0;
        }
        ApplyDebugToSurfaceData(fragInputs.tangentToWorld, surfaceData);
    #endif
                
    // 环境光遮蔽 AO
    #if defined(_SPECULAR_OCCLUSION_CUSTOM)
    #elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
        surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
    #elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
        surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
    #endif
                
    #if defined(_ENABLE_GEOMETRIC_SPECULAR_AA) && !defined(SHADER_STAGE_RAY_TRACING)
        surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.tangentToWorld[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
    #endif
}
 
 


/* ******************************************
    构建 SurfaceData 和 BuiltinData 数据
* *******************************************/
void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData RAY_TRACING_OPTIONAL_PARAMETERS)
{
    #if !defined(SHADER_STAGE_RAY_TRACING) && !defined(_TESSELLATION_DISPLACEMENT)
        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
            LODDitheringTransition(ComputeFadeMaskSeed(V, posInput.positionSS), unity_LODFade.x);
        #endif
    #endif
        
    #ifndef SHADER_UNLIT
        #ifdef _DOUBLESIDED_ON
            float3 doubleSidedConstants = _DoubleSidedConstants.xyz;
        #else
            float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
        #endif
        ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants); 
    #endif // SHADER_UNLIT
                
    // 进行表面数据的自定义构建
    SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
    #if defined(HAVE_VFX_MODIFICATION)
        GraphProperties properties;
        ZERO_INITIALIZE(GraphProperties, properties);
        GetElementPixelProperties(fragInputs, properties);
        SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
    #else
        SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
    #endif
        
    // Alpha Test测试
    #ifdef _ALPHATEST_ON
        float alphaCutoff = surfaceDescription.AlphaClipThreshold;
        #if SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_PREPASS
        #elif SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_POSTPASS
            alphaCutoff = surfaceDescription.AlphaClipThresholdDepthPostpass;
        #elif (SHADERPASS == SHADERPASS_SHADOWS) || (SHADERPASS == SHADERPASS_RAYTRACING_VISIBILITY)
        #endif
        GENERIC_ALPHA_TEST(surfaceDescription.Alpha, alphaCutoff);
    #endif
        
    #if !defined(SHADER_STAGE_RAY_TRACING) && _DEPTHOFFSET_ON
        ApplyDepthOffsetPositionInput(V, surfaceDescription.DepthOffset, GetViewForwardDir(), GetWorldToHClipMatrix(), posInput);
    #endif
                
    // Builtin Data 构建
    #ifndef SHADER_UNLIT
        float3 bentNormalWS;
        BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData, bentNormalWS);
        
        #ifdef FRAG_INPUTS_USE_TEXCOORD1
            float4 lightmapTexCoord1 = fragInputs.texCoord1;
        #else
            float4 lightmapTexCoord1 = float4(0,0,0,0);
        #endif
        
        #ifdef FRAG_INPUTS_USE_TEXCOORD2
            float4 lightmapTexCoord2 = fragInputs.texCoord2;
        #else
            float4 lightmapTexCoord2 = float4(0,0,0,0);
        #endif
        
        // Builtin Data
        // 对于背光，使用相反的顶点法线
        InitBuiltinData(posInput, surfaceDescription.Alpha, bentNormalWS, -fragInputs.tangentToWorld[2], lightmapTexCoord1, lightmapTexCoord2, builtinData);
        
    #else
        BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
        
        ZERO_BUILTIN_INITIALIZE(builtinData);
        builtinData.opacity = surfaceDescription.Alpha; // 透明度
        
        #if defined(DEBUG_DISPLAY)
            builtinData.renderingLayers = GetMeshRenderingLightLayer(); // 光照渲染层
        #endif
        
    #endif
                
    // AlphaTest
    #ifdef _ALPHATEST_ON
        builtinData.alphaClipTreshold = alphaCutoff;
    #endif
                
    // 自发光颜色
    builtinData.emissiveColor = surfaceDescription.Emission;
                
    #ifdef UNITY_VIRTUAL_TEXTURING
        builtinData.vtPackedFeedback = surfaceDescription.VTPackedFeedback;
    #endif
                
    // 深度偏移
    #if _DEPTHOFFSET_ON
        builtinData.depthOffset = surfaceDescription.DepthOffset;
    #endif
                
    // 扭曲、变形
    #if (SHADERPASS == SHADERPASS_DISTORTION)
        builtinData.distortion = surfaceDescription.Distortion;
        builtinData.distortionBlur = surfaceDescription.DistortionBlur;
    #endif
                
    // 应用Builtin Data
    #ifndef SHADER_UNLIT
        PostInitBuiltinData(V, posInput, surfaceData, builtinData);
    #else
        ApplyDebugToBuiltinData(builtinData);
    #endif
        
    RAY_TRACING_OPTIONAL_ALPHA_TEST_PASS
}




#endif //构建Surface和Builtin数据（由 Graphi 着色库工具生成）| 作者：强辰