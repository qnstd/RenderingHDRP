﻿#ifndef FURSTRUCTDEFINES
#define FURSTRUCTDEFINES

// 顶点输入结构需要的数据
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3

// 数据插值转换时需要的数据
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_POSITIONPREDISPLACEMENT_WS
#define VARYINGS_NEED_TANGENT_TO_WORLD
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_TEXCOORD3
   
// 片元输入需要的数据
//#if !defined(SHADER_STAGE_RAY_TRACING) && SHADERPASS != SHADERPASS_RAYTRACING_GBUFFER && SHADERPASS != SHADERPASS_FULL_SCREEN_DEBUG
//    #define FRAG_INPUTS_ENABLE_STRIPPING
//#endif
//#define FRAG_INPUTS_USE_TEXCOORD0
//#define FRAG_INPUTS_USE_TEXCOORD1
//#define FRAG_INPUTS_USE_TEXCOORD2
//#define FRAG_INPUTS_USE_TEXCOORD3


#endif //数据结构宏定义（由 Graphi 着色库工具生成）| 作者：强辰