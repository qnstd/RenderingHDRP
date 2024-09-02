#ifndef GRAPHI_LITINCLUDE
#define GRAPHI_LITINCLUDE

// Shader 编译版本
#pragma target 4.5
// 渲染平台
#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
// DOTs ECS 混合渲染
#pragma multi_compile _ DOTS_INSTANCING_ON
// 渲染层
#pragma instancing_options renderinglayer
// GPU Instance 实例
#pragma multi_compile_instancing

// 变体/关键字
#pragma shader_feature _ _SURFACE_TYPE_TRANSPARENT          // 是否支持透明
#pragma shader_feature_local _ _DOUBLESIDED_ON              // 双边投影    
#pragma shader_feature_local _ _ADD_PRECOMPUTED_VELOCITY    
#pragma shader_feature_local _ _TRANSPARENT_WRITES_MOTION_VEC       //透明对象的运动模糊（暂时框架中不支持运动模糊渲染通道）
#pragma shader_feature_local_fragment _ _ENABLE_FOG_ON_TRANSPARENT  //透明对象是否被雾影响
#pragma shader_feature_local_fragment _ _DISABLE_DECALS             //禁用贴花
#pragma shader_feature_local_raytracing _ _DISABLE_DECALS
#pragma shader_feature_local_fragment _ _DISABLE_SSR                //禁用SSR
#pragma shader_feature_local_raytracing _ _DISABLE_SSR
#pragma shader_feature_local_fragment _ _DISABLE_SSR_TRANSPARENT    //禁用SSR，透明
#pragma shader_feature_local_raytracing _ _DISABLE_SSR_TRANSPARENT
#pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN     //折射

// include文件
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl" 
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Tessellation.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphHeader.hlsl" 

/////////////////////////////////////////////////////////////////////////
// 定义

#define HAVE_MESH_MODIFICATION
#if !defined(SHADER_STAGE_RAY_TRACING) && SHADERPASS != SHADERPASS_RAYTRACING_GBUFFER && SHADERPASS != SHADERPASS_FULL_SCREEN_DEBUG
#define FRAG_INPUTS_ENABLE_STRIPPING
#endif

// 解决10.1光线追踪品质的优化
#define RAYTRACING_SHADER_GRAPH_DEFAULT
#ifdef RAYTRACING_SHADER_GRAPH_DEFAULT
#define RAYTRACING_SHADER_GRAPH_HIGH
#endif
#ifdef RAYTRACING_SHADER_GRAPH_RAYTRACED
#define RAYTRACING_SHADER_GRAPH_LOW
#endif

// 双边，开启 IsFrontFace 参数
#ifndef SHADER_UNLIT
#if defined(_DOUBLESIDED_ON) && !defined(VARYINGS_NEED_CULLFACE)
    #define VARYINGS_NEED_CULLFACE
#endif
#endif

// 高光遮蔽模式
#define _SPECULAR_OCCLUSION_FROM_AO 1
// 能量守恒
#define _ENERGY_CONSERVING_SPECULAR 1

// 使用次表面散射，并且不是透明类型。则开启输出分割照明。
#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
    #define OUTPUT_SPLIT_LIGHTING
#endif

// 支持光追递归渲染
#define HAVE_RECURSIVE_RENDERING

// 使用薄折射模型
#if (SHADERPASS == SHADERPASS_PATH_TRACING) && !defined(_DOUBLESIDED_ON) && (defined(_REFRACTION_PLANE) || defined(_REFRACTION_SPHERE))
    #undef  _REFRACTION_PLANE
    #undef  _REFRACTION_SPHERE
    #define _REFRACTION_THIN
#endif

// 当shaderpass为透明深度预处理时，对SSR的判定，是否需要开启写入法线
#if SHADERPASS == SHADERPASS_TRANSPARENT_DEPTH_PREPASS
#if !defined(_DISABLE_SSR_TRANSPARENT) && !defined(SHADER_UNLIT)
    #define WRITE_NORMAL_BUFFER
#endif
#endif

// 非透明对象的Alpha Test
#ifndef DEBUG_DISPLAY
    #if !defined(_SURFACE_TYPE_TRANSPARENT)
        #if SHADERPASS == SHADERPASS_FORWARD
        #define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST
        #elif SHADERPASS == SHADERPASS_GBUFFER
        #define SHADERPASS_GBUFFER_BYPASS_ALPHA_TEST
        #endif
    #endif
#endif
        
// 非透明对象渲染下，支持延迟渲染
#if defined(SHADER_LIT) && !defined(_SURFACE_TYPE_TRANSPARENT)
    #define _DEFERRED_CAPABLE_MATERIAL
#endif
        
// 如果是透明渲染类型且开启需要透明运动矢量写入，则定义
#if defined(_TRANSPARENT_WRITES_MOTION_VEC) && defined(_SURFACE_TYPE_TRANSPARENT)
    #define _WRITE_TRANSPARENT_MOTION_VECTOR
#endif

#endif //带光照参与的着色器包含的必备项（由 Graphi 着色库工具生成）| 作者：强辰