#ifndef LW_BUILTINANDSURFACEDATA
#define LW_BUILTINANDSURFACEDATA


#if SHADERPASS != SHADERPASS_SHADOWS
    #include "../../HLSL/LitStandardVari.hlsl"
#endif


/*
    修改底层关于世界法线的生成
*/
void GetNormalWS_Replace(FragInputs input, float3 normalTS, out float3 normalWS)
{
// ///////////////////////////////
// Unity 底层源码计算
// ///////////////////////////////

//#if defined(SURFACE_GRADIENT)
//    GetNormalWS_SG(input, normalTS, normalWS, doubleSidedConstants);
//#else

//    #ifdef _DOUBLESIDED_ON
//        float flipSign = input.isFrontFace ? 1.0 : doubleSidedConstants.x;
//        normalTS.xy *= flipSign;
//    #endif // _DOUBLESIDED_ON

//    normalWS = SafeNormalize(TransformTangentToWorld(normalTS, input.tangentToWorld));
//#endif

// ///////////////////////////////
// 自定义计算
// ///////////////////////////////
    float3 finTangentWS = input.finTangentWS;
    float3 geomNormalWS = input.tangentToWorld[2];
    float3 viewDirWS = SafeNormalize(GetCameraPositionWS() - input.positionRWS);
    float3 bitangent = SafeNormalize(viewDirWS.y * cross(geomNormalWS, finTangentWS));
    normalWS = SafeNormalize(TransformTangentToWorld( normalTS, float3x3(finTangentWS, bitangent, geomNormalWS)));
}


/*
    贴花及贴花法线相关计算
*/
void ApplyDecalToSurfaceDataNoNormal(DecalSurfaceData decalSurfaceData, inout SurfaceData surfaceData);
void ApplyDecalAndGetNormal(FragInputs fragInputs, PositionInputs posInput, SurfaceDescription surfaceDescription, inout SurfaceData surfaceData)
{
    float3 doubleSidedConstants = GetDoubleSidedConstants();
        
    #ifdef DECAL_NORMAL_BLENDING
        
        float3 normalTS;
        #if SHADERPASS != SHADERPASS_SHADOWS
            normalTS = SurfaceGradientFromTangentSpaceNormalAndFromTBN(surfaceDescription.NormalTS, fragInputs.tangentToWorld[0], fragInputs.tangentToWorld[1]);
        #else
            normalTS = float3(0,0,1);
        #endif

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
        #if SHADERPASS != SHADERPASS_SHADOWS
        //GetNormalWS(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS, doubleSidedConstants);
        GetNormalWS_Replace(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS);
        #endif

        #if HAVE_DECALS
        if (_EnableDecals)
        {
            float alpha = 1.0;
            alpha = surfaceDescription.Alpha;
        
            DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, fragInputs, alpha);
            ApplyDecalToSurfaceNormal(decalSurfaceData, surfaceData.normalWS.xyz);
            ApplyDecalToSurfaceDataNoNormal(decalSurfaceData, surfaceData);
        }
        #endif
    #endif
}




/*
    构建表面渲染数据
*/
void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
{
    ZERO_INITIALIZE(SurfaceData, surfaceData);
    surfaceData.specularOcclusion = 1.0;
        
    #if SHADERPASS != SHADERPASS_SHADOWS
    surfaceData.baseColor =                 surfaceDescription.BaseColor;
    surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
    surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
    surfaceData.metallic =                  surfaceDescription.Metallic;
    surfaceData.coatMask =                  surfaceDescription.CoatMask;
    #endif
        
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


/*
    自定义表面数据
*/
SurfaceDescription SurfaceDescriptionFunction(FragInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;

    // 毛发
    float2 furuv = IN.finUV;
    float4 fur = SAMPLE_TEXTURE2D_X(_FurTex, sampler_FurTex, furuv);
    if(furuv.x >= 0.0 && fur.a < _CutAlpha) discard;


    #if SHADERPASS != SHADERPASS_SHADOWS
        float2 uv0 = IN.texCoord0.xy;
        UnityTexture2D albedotex = UnityBuildTexture2DStructNoScale(_AlbedoTex);
        UnityTexture2D detailtex = UnityBuildTexture2DStructNoScale(_DetailTex);
        float2 tilling = float2(_TillingAndOffset.x, _TillingAndOffset.y);
        float2 offsets = float2(_TillingAndOffset.z, _TillingAndOffset.w);

        // 计算细节信息（细节法线失效）
        float detail_albedo;
        float3 detail_normal;
        float detail_smooth;
        CalculateDetail_float(_LockAlbedoTillingAndOffset, detailtex, _DetailTillingAndOffset, uv0, _DetailNormalScal, tilling, offsets, detail_albedo, detail_normal, detail_smooth);

        // 计算缩放及偏移
        float2 tillingAndOffset = uv0 * tilling + offsets;

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
        CalculateEmssion_float(albedocolor, _MultiplyAlbedo, emissColor, emisstex, emissExposure, _ExposureWeight, uv0, emissioncolor);

        // 计算反照率光线遮蔽
        float albedoOcc = sqrt(lerp(1.0 - _Occ, 1.0, max(furuv.y, 0.0))); 
        albedocolor *= albedoOcc;

        // 计算法线（这里取消传统的法线计算，使用毛发相关的计算方式）
        //UnityTexture2D ntex = UnityBuildTexture2DStructNoScale(_NormalTex);
        //float3 normalts;
        //CalculateNormal_float(ntex, _NormalStrength, detail_normal, tillingAndOffset, detailmask, normalts);
	    float4 n = SAMPLE_TEXTURE2D(_FurNormalTex, sampler_FurNormalTex, furuv);
	    n.rgb = UnpackNormal(n);
	    float3 normalts = float3(n.rg * _FurNormalForce, lerp(1, n.b, saturate(_FurNormalForce)));


        // 计算清漆
        UnityTexture2D coatmasktex = UnityBuildTexture2DStructNoScale(_CoatMask);
        float coatval;
        CalculateCoat_float(_Coat, coatmasktex, tillingAndOffset, coatval);

        // 赋值
        surface.BaseColor = albedocolor;
        surface.Emission = emissioncolor;
        surface.BentNormal = float3(0.0f, 0.0f, 1.0f);
        surface.Smoothness = smoothness;
        surface.Occlusion = amocc;
        surface.NormalTS = normalts;
        surface.CoatMask = coatval;
        surface.Metallic = metalness;
    #endif
    
    // Alpha & Alpha Test
    surface.Alpha = 1.0;
    surface.AlphaClipThreshold = 0.0;
    surface.AlphaClipThresholdShadow = 0.5;

    return surface;
}


/*
    计算并构建表面数据，用于后续的相关计算
*/
void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData RAY_TRACING_OPTIONAL_PARAMETERS)
{
    //#if !defined(SHADER_STAGE_RAY_TRACING) && !defined(_TESSELLATION_DISPLACEMENT)
    //// 在 LODGroup 组件中开启了 CrossFade 属性
    //#ifdef LOD_FADE_CROSSFADE
    //    LODDitheringTransition(ComputeFadeMaskSeed(V, posInput.positionSS), unity_LODFade.x);
    //#endif
    //#endif

    #ifdef _DOUBLESIDED_ON
        float3 doubleSidedConstants = _DoubleSidedConstants.xyz;
    #else
        float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
    #endif
    ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants); 
        
    // 构建自定义表面数据信息
    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(fragInputs);
        
    #ifdef _ALPHATEST_ON
        float alphaCutoff = surfaceDescription.AlphaClipThreshold;
        #if SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_PREPASS
                      
        #elif SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_POSTPASS
        // 总是使用自己的alpha阈值
        alphaCutoff = surfaceDescription.AlphaClipThresholdDepthPostpass;
        #elif (SHADERPASS == SHADERPASS_SHADOWS) || (SHADERPASS == SHADERPASS_RAYTRACING_VISIBILITY)
        // 如果使用阴影阈值不启用，不允许任何测试
        alphaCutoff = _UseShadowThreshold ? surfaceDescription.AlphaClipThresholdShadow : alphaCutoff;
        #endif
        
        GENERIC_ALPHA_TEST(surfaceDescription.Alpha, alphaCutoff);
    #endif
        
    #if !defined(SHADER_STAGE_RAY_TRACING) && _DEPTHOFFSET_ON
    ApplyDepthOffsetPositionInput(V, surfaceDescription.DepthOffset, GetViewForwardDir(), GetWorldToHClipMatrix(), posInput);
    #endif
        
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
        
    InitBuiltinData(posInput, surfaceDescription.Alpha, bentNormalWS, -fragInputs.tangentToWorld[2], lightmapTexCoord1, lightmapTexCoord2, builtinData);
        
    #ifdef _ALPHATEST_ON
        // alpha 测试
        builtinData.alphaClipTreshold = alphaCutoff;
    #endif
        
    #if SHADERPASS != SHADERPASS_SHADOWS
    builtinData.emissiveColor = surfaceDescription.Emission;
    #endif
        
    //#ifdef UNITY_VIRTUAL_TEXTURING
    //#endif
        
    #if _DEPTHOFFSET_ON
    builtinData.depthOffset = surfaceDescription.DepthOffset;
    #endif
        
    #if (SHADERPASS == SHADERPASS_DISTORTION)
    builtinData.distortion = surfaceDescription.Distortion;
    builtinData.distortionBlur = surfaceDescription.DistortionBlur;
    #endif
        
    PostInitBuiltinData(V, posInput, surfaceData, builtinData);
                   
    RAY_TRACING_OPTIONAL_ALPHA_TEST_PASS
}


#endif //构建表面数据 | 作者：强辰