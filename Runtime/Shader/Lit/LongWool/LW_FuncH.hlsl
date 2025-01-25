#ifndef LW_FUNCH
#define LW_FUNCH

// /////////////////////////////////////////////////////////
// ///////////////////////  Pragmas  ///////////////////////
// /////////////////////////////////////////////////////////


// 着色等级（支持曲面细分及几何操作）
#pragma target 4.7

// 着色平台
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

// 支持 DOTs
#pragma multi_compile _ DOTS_INSTANCING_ON
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer

// ///////////////////////////////
// 着色阶段

//- 顶点着色程序
#pragma vertex Vert

//- 曲面细分着色程序
#pragma hull Hull
#pragma domain Domain

//- 几何着色程序
#pragma geometry Geom

//- 片元着色程序
#pragma fragment Frag

// END
// ///////////////////////////////


// /////////////////////////////////////////////////////////
// ////////////////////  Keywords  /////////////////////////
// /////////////////////////////////////////////////////////
#if SHADERPASS == SHADERPASS_FORWARD
    // 前向
	#pragma multi_compile_fragment PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
	#pragma multi_compile_raytracing PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
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
    // 延迟
    #define LIGHT_LAYERS
    #pragma multi_compile_fragment PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
    #pragma multi_compile_raytracing PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
    #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
    #pragma multi_compile_raytracing _ SHADOWS_SHADOWMASK
    #pragma multi_compile_fragment DECALS_OFF DECALS_3RT DECALS_4RT
    #pragma multi_compile_fragment _ DECAL_SURFACE_GRADIENT
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_DEPTH_ONLY
    // 深度
    #pragma multi_compile _ WRITE_NORMAL_BUFFER
    #pragma multi_compile_fragment _ WRITE_MSAA_DEPTH
    #pragma multi_compile _ WRITE_DECAL_BUFFER
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_SHADOWS
    // 投影
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#elif SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
    // GI (Meta)
    #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN

#endif


// 清漆变体（若开启此变体，并且同时开启了SSGI、SSR等屏幕空间相关操作，则法线缓冲中不包含当前的模型数据）
#pragma shader_feature_local_fragment _MATERIAL_FEATURE_CLEAR_COAT
// 绘制源网格信息
#pragma shader_feature_local _DRAW_ORIGIN_MESH


// /////////////////////////////////////////////////////////
// ////////////////////  Base Include  /////////////////////
// /////////////////////////////////////////////////////////

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl" 
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Tessellation.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl" 
#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/Functions.hlsl"
#include "LW_Attributes.hlsl"  
#include "LW_FragInputs.hlsl"



// /////////////////////////////////////////////////////////
// //////////////////////  Defines  ////////////////////////
// /////////////////////////////////////////////////////////

// Alpha测试
#define _ALPHATEST_ON
// 禁用接收 SSR，认为毛发不接受 SSR 反射
#define _DISABLE_SSR 
// 禁用接收贴花
//#define _DISABLE_DECALS
// 光线追踪
//#define HAVE_RECURSIVE_RENDERING


#if SHADERPASS == SHADERPASS_FORWARD
    #define SUPPORT_BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
    #define HAS_LIGHTLOOP 1
    #define SHADER_LIT 1
#endif
#define RAYTRACING_SHADER_GRAPH_DEFAULT
        
#ifdef RAYTRACING_SHADER_GRAPH_DEFAULT
#define RAYTRACING_SHADER_GRAPH_HIGH
#endif
        
#ifdef RAYTRACING_SHADER_GRAPH_RAYTRACED
#define RAYTRACING_SHADER_GRAPH_LOW
#endif
        
#if defined(_DOUBLESIDED_ON) && !defined(VARYINGS_NEED_CULLFACE)
    #define VARYINGS_NEED_CULLFACE
#endif
        

#define _SPECULAR_OCCLUSION_FROM_AO 1
#define _ENERGY_CONSERVING_SPECULAR 1
#if SHADERPASS != SHADERPASS_SHADOWS
    #define _AMBIENT_OCCLUSION 1
#endif

        
#if (SHADERPASS == SHADERPASS_PATH_TRACING) && !defined(_DOUBLESIDED_ON) && (defined(_REFRACTION_PLANE) || defined(_REFRACTION_SPHERE))
    #undef  _REFRACTION_PLANE
    #undef  _REFRACTION_SPHERE
    #define _REFRACTION_THIN
#endif
            
#if SHADERPASS == SHADERPASS_FORWARD
#define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST
#elif SHADERPASS == SHADERPASS_GBUFFER
#define SHADERPASS_GBUFFER_BYPASS_ALPHA_TEST
#endif
        
#if defined(SHADER_LIT) && !defined(_SURFACE_TYPE_TRANSPARENT)
    #define _DEFERRED_CAPABLE_MATERIAL
#endif

#if SHADERPASS == SHADERPASS_LIGHT_TRANSPORT
    #define EDITOR_VISUALIZATION
#endif


// /////////////////////////////////////////////////////////
// //////////////////// Function Include ///////////////////
// /////////////////////////////////////////////////////////

#include "LW_Properties.hlsl"
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

#include "LW_StructAndPacking.hlsl"
#include "LW_BuiltinAndSurfaceData.hlsl"



#endif //头文件 | 作者：强辰