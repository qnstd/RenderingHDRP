#ifndef FURH
#define FURH

// ///////////////////////////////////////////////////////////////////////////////
// 变体 
#if SHADERPASS == SHADERPASS_FORWARD
// 前向
    #pragma shader_feature _ _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature_local _ _DOUBLESIDED_ON
    #pragma shader_feature_local _ _ADD_PRECOMPUTED_VELOCITY
    #pragma shader_feature_local _ _TRANSPARENT_WRITES_MOTION_VEC
    #pragma shader_feature_local_fragment _ _ENABLE_FOG_ON_TRANSPARENT
    #pragma multi_compile _ DEBUG_DISPLAY
    #pragma shader_feature_local_fragment _ _DISABLE_DECALS
    #pragma shader_feature_local_raytracing _ _DISABLE_DECALS
    #pragma shader_feature_local_fragment _ _DISABLE_SSR
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR
    #pragma shader_feature_local_fragment _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR_TRANSPARENT
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile_fragment PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
    #pragma multi_compile_raytracing PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
    #pragma multi_compile _ DYNAMICLIGHTMAP_ON
    #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
    #pragma multi_compile_raytracing _ SHADOWS_SHADOWMASK
    #pragma multi_compile_fragment DECALS_OFF DECALS_3RT DECALS_4RT
    #pragma multi_compile_fragment _ DECAL_SURFACE_GRADIENT
    #pragma multi_compile_fragment SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH
    #pragma multi_compile_fragment AREA_SHADOW_MEDIUM AREA_SHADOW_HIGH
    #pragma multi_compile_fragment SCREEN_SPACE_SHADOWS_OFF SCREEN_SPACE_SHADOWS_ON
    #pragma multi_compile_fragment USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_GBUFFER 
// GBuffer
    #pragma multi_compile_fragment _ LIGHT_LAYERS
    #pragma multi_compile_raytracing _ LIGHT_LAYERS
    #pragma shader_feature _ _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature_local _ _DOUBLESIDED_ON
    #pragma shader_feature_local _ _ADD_PRECOMPUTED_VELOCITY
    #pragma shader_feature_local _ _TRANSPARENT_WRITES_MOTION_VEC
    #pragma shader_feature_local_fragment _ _ENABLE_FOG_ON_TRANSPARENT
    #pragma multi_compile _ DEBUG_DISPLAY
    #pragma shader_feature_local_fragment _ _DISABLE_DECALS
    #pragma shader_feature_local_raytracing _ _DISABLE_DECALS
    #pragma shader_feature_local_fragment _ _DISABLE_SSR
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR
    #pragma shader_feature_local_fragment _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR_TRANSPARENT
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile_fragment PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
    #pragma multi_compile_raytracing PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
    #pragma multi_compile _ DYNAMICLIGHTMAP_ON
    #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
    #pragma multi_compile_raytracing _ SHADOWS_SHADOWMASK
    #pragma multi_compile_fragment DECALS_OFF DECALS_3RT DECALS_4RT
    #pragma multi_compile_fragment _ DECAL_SURFACE_GRADIENT
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY
// 深度
    #pragma multi_compile _ WRITE_NORMAL_BUFFER
    #pragma multi_compile_fragment _ WRITE_MSAA_DEPTH
    #pragma shader_feature _ _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature_local _ _DOUBLESIDED_ON
    #pragma shader_feature_local _ _ADD_PRECOMPUTED_VELOCITY
    #pragma shader_feature_local _ _TRANSPARENT_WRITES_MOTION_VEC
    #pragma shader_feature_local_fragment _ _ENABLE_FOG_ON_TRANSPARENT
    #pragma shader_feature_local_fragment _ _DISABLE_DECALS
    #pragma shader_feature_local_raytracing _ _DISABLE_DECALS
    #pragma shader_feature_local_fragment _ _DISABLE_SSR
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR
    #pragma shader_feature_local_fragment _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR_TRANSPARENT
    #pragma multi_compile _ WRITE_DECAL_BUFFER
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_MOTION_VECTORS
// 运动模糊
    #pragma multi_compile_fragment _ WRITE_MSAA_DEPTH
    #pragma shader_feature _ _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature_local _ _DOUBLESIDED_ON
    #pragma shader_feature_local _ _ADD_PRECOMPUTED_VELOCITY
    #pragma shader_feature_local _ _TRANSPARENT_WRITES_MOTION_VEC
    #pragma shader_feature_local_fragment _ _ENABLE_FOG_ON_TRANSPARENT
    #pragma multi_compile _ WRITE_NORMAL_BUFFER
    #pragma shader_feature_local_fragment _ _DISABLE_DECALS
    #pragma shader_feature_local_raytracing _ _DISABLE_DECALS
    #pragma shader_feature_local_fragment _ _DISABLE_SSR
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR
    #pragma shader_feature_local_fragment _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR_TRANSPARENT
    #pragma multi_compile _ WRITE_DECAL_BUFFER
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
// Meta GI
    #pragma shader_feature _ EDITOR_VISUALIZATION
    #pragma shader_feature _ _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature_local _ _DOUBLESIDED_ON
    #pragma shader_feature_local _ _ADD_PRECOMPUTED_VELOCITY
    #pragma shader_feature_local _ _TRANSPARENT_WRITES_MOTION_VEC
    #pragma shader_feature_local_fragment _ _ENABLE_FOG_ON_TRANSPARENT
    #pragma shader_feature_local_fragment _ _DISABLE_DECALS
    #pragma shader_feature_local_raytracing _ _DISABLE_DECALS
    #pragma shader_feature_local_fragment _ _DISABLE_SSR
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR
    #pragma shader_feature_local_fragment _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_SHADOWS
// shadows
    #pragma shader_feature _ _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature_local _ _DOUBLESIDED_ON
    #pragma shader_feature_local _ _ADD_PRECOMPUTED_VELOCITY
    #pragma shader_feature_local _ _TRANSPARENT_WRITES_MOTION_VEC
    #pragma shader_feature_local_fragment _ _ENABLE_FOG_ON_TRANSPARENT
    #pragma shader_feature_local_fragment _ _DISABLE_DECALS
    #pragma shader_feature_local_raytracing _ _DISABLE_DECALS
    #pragma shader_feature_local_fragment _ _DISABLE_SSR
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR
    #pragma shader_feature_local_fragment _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local_raytracing _ _DISABLE_SSR_TRANSPARENT
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#endif
// 结束
// ///////////////////////////////////////////////////////////////////////////////




// ///////////////////////////////////////////////////////////////////////////////
// 前置包含项 
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Tessellation.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
// 结束
// ///////////////////////////////////////////////////////////////////////////////



// ///////////////////////////////////////////////////////////////////////////////
// 宏定义 
#define HAVE_MESH_MODIFICATION
#define _ALPHATEST_ON


#if SHADERPASS == SHADERPASS_FORWARD
    #define SUPPORT_BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
    #define HAS_LIGHTLOOP 1
    #define SHADER_LIT 1
#endif

#if SHADERPASS == SHADERPASS_FORWARD || SHADERPASS == SHADERPASS_GBUFFER || SHADERPASS == SHADERPASS_DEPTH_ONLY || SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
    #define RAYTRACING_SHADER_GRAPH_DEFAULT
#endif

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
    #define SCENEPICKINGPASS 1
#endif

#ifdef RAYTRACING_SHADER_GRAPH_DEFAULT
    #define RAYTRACING_SHADER_GRAPH_HIGH
#endif
        
#ifdef RAYTRACING_SHADER_GRAPH_RAYTRACED
    #define RAYTRACING_SHADER_GRAPH_LOW
#endif
        
#ifndef SHADER_UNLIT
    #if defined(_DOUBLESIDED_ON) && !defined(VARYINGS_NEED_CULLFACE)
        #define VARYINGS_NEED_CULLFACE
    #endif
#endif

#define _MATERIAL_FEATURE_CLEAR_COAT

#if SHADERPASS != SHADERPASS_SHADOWS
    #define _AMBIENT_OCCLUSION 1
#endif

#define _SPECULAR_OCCLUSION_FROM_AO 1
#define _ENERGY_CONSERVING_SPECULAR 1

#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
    #define OUTPUT_SPLIT_LIGHTING
#endif

// 光线追踪的递归渲染模式
//#define HAVE_RECURSIVE_RENDERING

#if (SHADERPASS == SHADERPASS_PATH_TRACING) && !defined(_DOUBLESIDED_ON) && (defined(_REFRACTION_PLANE) || defined(_REFRACTION_SPHERE))
    #undef  _REFRACTION_PLANE
    #undef  _REFRACTION_SPHERE
    #define _REFRACTION_THIN
#endif
            
#if SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_PREPASS
    #if !defined(_DISABLE_SSR_TRANSPARENT) && !defined(SHADER_UNLIT)
        #define WRITE_NORMAL_BUFFER
    #endif
#endif
        
#ifndef DEBUG_DISPLAY
    #if !defined(_SURFACE_TYPE_TRANSPARENT)
        #if SHADERPASS == SHADERPASS_FORWARD
            #define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST
        #elif SHADERPASS == SHADERPASS_GBUFFER
            #define SHADERPASS_GBUFFER_BYPASS_ALPHA_TEST
        #endif
    #endif
#endif
        
#if defined(SHADER_LIT) && !defined(_SURFACE_TYPE_TRANSPARENT)
    #define _DEFERRED_CAPABLE_MATERIAL
#endif
        
#if defined(_TRANSPARENT_WRITES_MOTION_VEC) && defined(_SURFACE_TYPE_TRANSPARENT)
    #define _WRITE_TRANSPARENT_MOTION_VECTOR
#endif
// 结束
// ///////////////////////////////////////////////////////////////////////////////



// ///////////////////////////////////////////////////////////////////////////////
// 后置包含项
#include "FurStructDefines.hlsl"
#include "FurProperties.hlsl"

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/PickingSpaceTransforms.hlsl"
#endif

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"

#if SHADERPASS == SHADERPASS_FORWARD
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
#endif
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
#if SHADERPASS == SHADERPASS_FORWARD
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
#endif

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

#if SHADERPASS != SHADERPASS_SHADOWS
    #include "../../HLSL/Tex.hlsl"
    #include "../../HLSL/LitStandardVari.hlsl"
#endif

#include "FurStructAndPack.hlsl"
#include "FurSurfaceAndBuiltinData.hlsl"

// 渲染库
#if SHADERPASS == SHADERPASS_FORWARD
    #include "FurShaderPassForward.hlsl"

#elif SHADERPASS == SHADERPASS_GBUFFER
    #include "FurShaderPassGBuffer.hlsl"

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY || SHADERPASS == SHADERPASS_SHADOWS
    #include "FurShaderPassDepthOnly.hlsl"

#elif SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
    #include "FurShaderPassMeta.hlsl"

#elif SHADERPASS == SHADERPASS_MOTION_VECTORS
    #include "FurShaderPassMotionVector.hlsl"

#endif
// 结束
// ///////////////////////////////////////////////////////////////////////////////


#endif //绒毛各个Pass渲染通道的头文件.h（由 Graphi 着色库工具生成）| 作者：强辰