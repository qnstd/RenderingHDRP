#ifndef FURSURFACEANDBUILTINDATA
#define FURSURFACEANDBUILTINDATA



/*
    提供自定义的表面描述数据信息
*/
SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;

    // 计算绒毛
    float layer = IN.uv3.z;
    float2 uv0 = IN.uv0.xy;
    float fur = SAMPLE_TEXTURE2D(_FurMap, sampler_FurMap, TRANSFORM_TEX(uv0, _FurMap) * _Density).r;
    float alpclip = fur * (1.0 - layer);
    
    #if (SHADERPASS == SHADERPASS_SHADOWS)
        surface.Alpha = _Alp;
        surface.AlphaClip = alpclip;
        surface.AlphaClipThreshold = _Cutoffs;
    #else
        UnityTexture2D albedotex = UnityBuildTexture2DStructNoScale(_AlbedoTex);
        UnityTexture2D detailtex = UnityBuildTexture2DStructNoScale(_DetailTex);
        float2 tilling = float2(_TillingAndOffset.x, _TillingAndOffset.y);
        float2 offsets = float2(_TillingAndOffset.z, _TillingAndOffset.w);

        // 计算细节信息
        float detail_albedo;
        float3 detail_normal;
        float detail_smooth;
        CalculateDetail_float(_LockAlbedoTillingAndOffset, detailtex, _DetailTillingAndOffset, (IN.uv0.xy), _DetailNormalScal, tilling, offsets, detail_albedo, detail_normal, detail_smooth);

        // 计算缩放及偏移
        float2 tillingAndOffset = IN.uv0.xy * tilling + offsets;

        // 计算混合贴图数据
        UnityTexture2D masktex = UnityBuildTexture2DStructNoScale(_MaskTex);
        float detailmask;
        float metalness;
        float amocc;
        float smoothness;
        CalculateMADS_float(detail_smooth, _DetailSmoothnessScal, _SmoothRemapping, _Smoothness, _UseRemapping, _MetalRemapping, _Metalness, _AORemapping, tillingAndOffset, masktex, detailmask, metalness, amocc, smoothness);
    
        // 计算反照率颜色
        float3 albedocolor;
        CalculateAlbedo_float(albedotex, _Color, _DetailAlbedoScal, detail_albedo, tillingAndOffset, detailmask, albedocolor);
    
        // 计算自发光
        float4 emissColor = IsGammaSpace() ? LinearToSRGB(_EmissionClr) : _EmissionClr;
        UnityTexture2D emisstex = UnityBuildTexture2DStruct(_EmissionTex);
        #ifdef SHADERGRAPH_PREVIEW
            float emissExposure = 1.0;
        #else
            float emissExposure = GetInverseCurrentExposureMultiplier();
        #endif
        float3 emissioncolor;
        CalculateEmssion_float(albedocolor, _MultiplyAlbedo, emissColor, emisstex, emissExposure, _ExposureWeight, (IN.uv0.xy), emissioncolor);
    
        // 计算法线
        UnityTexture2D ntex = UnityBuildTexture2DStructNoScale(_NormalTex);
        float3 normalts;
        CalculateNormal_float(ntex, _NormalStrength, detail_normal, tillingAndOffset, detailmask, normalts);
	    // 绒毛法线
        float4 n = SAMPLE_TEXTURE2D(_FurNormalMap, sampler_FurNormalMap,  TRANSFORM_TEX(uv0, _FurNormalMap) * _Density);
	    n.rgb = UnpackNormal(n);
	    float3 n_fur = float3(n.rg * _FurNormalForce, lerp(1, n.b, saturate(_FurNormalForce)));
        normalts = BlendNormal_RNM2( normalts, n_fur );
    
        // 计算清漆
        UnityTexture2D coatmasktex = UnityBuildTexture2DStructNoScale(_CoatMask);
        float coatval;
        CalculateCoat_float(_Coat, coatmasktex, tillingAndOffset, coatval);

        // 赋值
        surface.BaseColor = albedocolor * lerp(1.0 - _Occlusion, 1.0, layer);
        surface.Emission = emissioncolor;
        surface.Alpha = _Alp;
        surface.AlphaClip = alpclip;
        surface.AlphaClipThreshold = _Cutoffs;
        surface.BentNormal = IN.TangentSpaceNormal;
        surface.Smoothness = smoothness;
        surface.Occlusion = amocc;
        surface.NormalTS = normalts;
        surface.CoatMask = coatval;
        surface.Metallic = metalness;
        {
            surface.VTPackedFeedback = float4(1.0f,1.0f,1.0f,1.0f);
        }
    #endif

    return surface;
}
        

        
void ApplyDecalToSurfaceDataNoNormal(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData);
        
void ApplyDecalAndGetNormal(FragInputs fragInputs, PositionInputs posInput, SurfaceDescription surfaceDescription,inout SurfaceData surfaceData)
{
    float3 doubleSidedConstants = GetDoubleSidedConstants();
        
    #ifdef DECAL_NORMAL_BLENDING
        float3 normalTS;
        normalTS = SurfaceGradientFromTangentSpaceNormalAndFromTBN(surfaceDescription.NormalTS,
        fragInputs.tangentToWorld[0], fragInputs.tangentToWorld[1]);
        
        #if HAVE_DECALS
        if (_EnableDecals)
        {
            float alpha = 1.0;
            alpha = surfaceDescription.Alpha;
        
            DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, fragInputs, alpha);
            ApplyDecalToSurfaceNormal(decalSurfaceData, fragInputs.tangentToWorld[2], normalTS);
            ApplyDecalToSurfaceDataNoNormal(decalSurfaceData, surfaceData);
        }
        #endif
        GetNormalWS_SG(fragInputs, normalTS, surfaceData.normalWS, doubleSidedConstants);

    #else
        GetNormalWS(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS, doubleSidedConstants);
        #if HAVE_DECALS
            if (_EnableDecals)
            {
                float alpha = 1.0;
                alpha = surfaceDescription.Alpha;
        
                // Both uses and modifies 'surfaceData.normalWS'.
                DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, fragInputs, alpha);
                ApplyDecalToSurfaceNormal(decalSurfaceData, surfaceData.normalWS.xyz);
                ApplyDecalToSurfaceDataNoNormal(decalSurfaceData, surfaceData);
            }
        #endif
    #endif
}



/*
    构建最终的表面数据
*/
void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
{

ZERO_INITIALIZE(SurfaceData, surfaceData);
        
surfaceData.specularOcclusion =         1.0;
surfaceData.baseColor =                 surfaceDescription.BaseColor;
surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
surfaceData.metallic =                  surfaceDescription.Metallic;
surfaceData.coatMask =                  surfaceDescription.CoatMask;
        
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
        
float3 doubleSidedConstants = GetDoubleSidedConstants();
ApplyDecalAndGetNormal(fragInputs, posInput, surfaceDescription, surfaceData);
        
surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];
surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz); 
        
bentNormalWS = surfaceData.normalWS;
surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
#ifdef DEBUG_DISPLAY
    if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
    {
        surfaceData.metallic = 0;
    }
    ApplyDebugToSurfaceData(fragInputs.tangentToWorld, surfaceData);
#endif
        

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
        

// Surface 和 Builtin 数据构建
// 此函数是 unity 光照底层甩出的接口，此接口正是实现自定义表面着色的接口
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
    #endif 
        
    SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
        
    #if defined(HAVE_VFX_MODIFICATION)
    GraphProperties properties;
    ZERO_INITIALIZE(GraphProperties, properties);
        
    GetElementPixelProperties(fragInputs, properties);
        
    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
    #else
    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
    #endif
        
    // Alpha 测试
    #ifdef _ALPHATEST_ON
        float alphaCutoff = surfaceDescription.AlphaClipThreshold;
        #if SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_PREPASS
        #elif SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_POSTPASS
            alphaCutoff = surfaceDescription.AlphaClipThresholdDepthPostpass;
        #elif (SHADERPASS == SHADERPASS_SHADOWS) || (SHADERPASS == SHADERPASS_RAYTRACING_VISIBILITY)
        #endif
        GENERIC_ALPHA_TEST(surfaceDescription.AlphaClip, alphaCutoff);
    #endif
        
    #if !defined(SHADER_STAGE_RAY_TRACING) && _DEPTHOFFSET_ON
    ApplyDepthOffsetPositionInput(V, surfaceDescription.DepthOffset, GetViewForwardDir(), GetWorldToHClipMatrix(), posInput);
    #endif
        
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
        
    // 构建builtin数据
    InitBuiltinData(posInput, surfaceDescription.Alpha, bentNormalWS, -fragInputs.tangentToWorld[2], lightmapTexCoord1, lightmapTexCoord2, builtinData);
        
    #else
    BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
        
    ZERO_BUILTIN_INITIALIZE(builtinData);
    builtinData.opacity = surfaceDescription.Alpha;
        
    #if defined(DEBUG_DISPLAY)
        builtinData.renderingLayers = GetMeshRenderingLightLayer();
    #endif
        
    #endif // SHADER_UNLIT
        
    #ifdef _ALPHATEST_ON
        builtinData.alphaClipTreshold = alphaCutoff;
    #endif
   
    builtinData.emissiveColor = surfaceDescription.Emission;
        
    #ifdef UNITY_VIRTUAL_TEXTURING
    builtinData.vtPackedFeedback = surfaceDescription.VTPackedFeedback;
    #endif
        
    #if _DEPTHOFFSET_ON
    builtinData.depthOffset = surfaceDescription.DepthOffset;
    #endif
        
    #if (SHADERPASS == SHADERPASS_DISTORTION)
    builtinData.distortion = surfaceDescription.Distortion;
    builtinData.distortionBlur = surfaceDescription.DistortionBlur;
    #endif
        
    #ifndef SHADER_UNLIT
    PostInitBuiltinData(V, posInput, surfaceData, builtinData);
    #else
    ApplyDebugToBuiltinData(builtinData);
    #endif
        
    RAY_TRACING_OPTIONAL_ALPHA_TEST_PASS
}

#endif //构建绒毛 Surface 和 Builtin 数据（由 Graphi 着色库工具生成）| 作者：强辰