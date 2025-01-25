/*
    长毛发
    标准物理光照、非透明渲染、曲面细分、几何着色

    渲染管线: High-Definition RenderPipeline

    作者：强辰
*/
Shader "Graphi/Lit/LongWool"
{
    Properties
    {
    // PBR
        _Color("Color", Color) = (1, 1, 1, 0)
        [NoScaleOffset]_AlbedoTex("AlbedoTex", 2D) = "white" {}
        [Normal][NoScaleOffset]_NormalTex("NormalTex", 2D) = "bump" {}
        _NormalStrength("NormalStrength", Range(0, 8)) = 1
        [NoScaleOffset]_MaskTex("MaskTex", 2D) = "white" {}
        _Metalness("Metalness", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        [ToggleUI]_UseRemapping("UseRemapping", Float) = 1
        _MetalRemapping("MetalRemapping", Vector) = (0, 1, 0, 0)
        _SmoothRemapping("SmoothRemapping", Vector) = (0, 1, 0, 0)
        _AORemapping("AORemapping", Vector) = (0, 1, 0, 0)
        [NoScaleOffset]_CoatMask("CoatMask", 2D) = "white" {}
        _Coat("Coat", Range(0, 1)) = 0
        _Alp("Alp", Range(0, 1)) = 1
        _TillingAndOffset("TillingAndOffset", Vector) = (1, 1, 0, 0)
        [NoScaleOffset]_DetailTex("DetailTex", 2D) = "linearGrey" {}
        [ToggleUI]_LockAlbedoTillingAndOffset("LockAlbedoTillingAndOffset", Float) = 1
        _DetailTillingAndOffset("DetailTillingAndOffset", Vector) = (1, 1, 0, 0)
        _DetailAlbedoScal("DetailAlbedoScal", Range(0, 2)) = 1
        _DetailNormalScal("DetailNormalScal", Range(0, 2)) = 1
        _DetailSmoothnessScal("DetailSmoothnessScal", Range(0, 2)) = 1
        [HDR]_EmissionClr("EmissionClr", Color) = (0, 0, 0, 0)
        _EmissionTex("EmissionTex", 2D) = "white" {}
        [ToggleUI]_MultiplyAlbedo("MultiplyAlbedo", Float) = 0
        _ExposureWeight("ExposureWeight", Range(0, 1)) = 1
    // Tesselation
        _TessFactor("_TessFactor", Range(1, 10)) = 5.0
        _TessMinDist("_TessMinDist", Range(0.1, 50)) = 1.0
        _TessMaxDist("_TessMaxDist", Range(0.1, 50)) = 10.0
    // Fur
        _FurTex("_FurTex", 2D) = "white"{}
        _FurNormalTex("_FurNormalTex", 2D) = "bump"{}
        _FurNormalForce("_FurNormal Force", Range(0.0,5.0)) = 0
        [Toggle]_DisplayOriginMesh("_DisplayOriginMesh", float) = 1
        _CutAlpha("_CutAlpha", Range(0.0, 1.0)) = 0.22
        _FaceNormalFactor("_FaceNormalFactor", Range(0, 0.5)) = 0.5
        _FaceViewThreshold("_FaceViewThreshold", Range(0,1.0)) = 1.0
        _Density("_Density",float) = 50
        _RandomDirection("_RandomDirection",Range(0,1)) = 0.3
        _Length("_Length", Range(0,1)) = 0.267
        [IntRange]_NearSurface("_NearSurface", Range(1,8)) = 4
        _BaseOffset("_BaseOffset", vector) = (0,-0.4,0,0)
        _WindAxisWeight("_WindAxisWeight", vector) = (0,0.4,0.2,0)
        _WindAxisSpeed("_WindAxisSpeed", vector) = (0.5,0.3,0.2,0)
        _WindPhase("_WindPhase",float) = 2
        _SwingPow("_SwingPow",float) = 3
        _Occ("Occ", Range(0.0, 1.0)) = 0.0


    // HideInInspector
        [HideInInspector]_EmissionColor("Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_RenderQueueType("Float", Float) = 1
        [HideInInspector][ToggleUI]_AddPrecomputedVelocity("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_DepthOffsetEnable("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_ConservativeDepthOffsetEnable("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_TransparentWritingMotionVec("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_AlphaCutoffEnable("Boolean", Float) = 1
        [HideInInspector]_TransparentSortPriority("_TransparentSortPriority", Float) = 0
        [HideInInspector][ToggleUI]_UseShadowThreshold("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_DoubleSidedEnable("Boolean", Float) = 0
        [HideInInspector][Enum(Flip, 0, Mirror, 1, None, 2)]_DoubleSidedNormalMode("Float", Float) = 2
        [HideInInspector]_DoubleSidedConstants("Vector4", Vector) = (1, 1, -1, 0)
        [HideInInspector][Enum(Auto, 0, On, 1, Off, 2)]_DoubleSidedGIMode("Float", Float) = 0
        [HideInInspector][ToggleUI]_TransparentDepthPrepassEnable("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_TransparentDepthPostpassEnable("Boolean", Float) = 0
        [HideInInspector]_SurfaceType("Float", Float) = 0
        [HideInInspector]_BlendMode("Float", Float) = 0
        [HideInInspector]_SrcBlend("Float", Float) = 1
        [HideInInspector]_DstBlend("Float", Float) = 0
        [HideInInspector]_AlphaSrcBlend("Float", Float) = 1
        [HideInInspector]_AlphaDstBlend("Float", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_TransparentZWrite("Boolean", Float) = 0
        [HideInInspector]_CullMode("Float", Float) = 2
        [HideInInspector][ToggleUI]_EnableFogOnTransparent("Boolean", Float) = 1
        [HideInInspector]_CullModeForward("Float", Float) = 2
        [HideInInspector][Enum(Front, 1, Back, 2)]_TransparentCullMode("Float", Float) = 2
        [HideInInspector][Enum(UnityEditor.Rendering.HighDefinition.OpaqueCullMode)]_OpaqueCullMode("Float", Float) = 2
        [HideInInspector]_ZTestDepthEqualForOpaque("Float", Int) = 3
        [HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTestTransparent("Float", Float) = 4
        [HideInInspector][ToggleUI]_TransparentBackfaceEnable("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_RequireSplitLighting("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_ReceivesSSR("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_ReceivesSSRTransparent("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_EnableBlendModePreserveSpecularLighting("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_SupportDecals("Boolean", Float) = 1
        [HideInInspector][ToggleUI]_ExcludeFromTUAndAA("Boolean", Float) = 0
        [HideInInspector]_StencilRef("Float", Int) = 0
        [HideInInspector]_StencilWriteMask("Float", Int) = 6
        [HideInInspector]_StencilRefDepth("Float", Int) = 8
        [HideInInspector]_StencilWriteMaskDepth("Float", Int) = 9
        [HideInInspector]_StencilRefMV("Float", Int) = 40
        [HideInInspector]_StencilWriteMaskMV("Float", Int) = 41
        [HideInInspector]_StencilRefDistortionVec("Float", Int) = 4
        [HideInInspector]_StencilWriteMaskDistortionVec("Float", Int) = 4
        [HideInInspector]_StencilWriteMaskGBuffer("Float", Int) = 15
        [HideInInspector]_StencilRefGBuffer("Float", Int) = 10
        [HideInInspector]_ZTestGBuffer("Float", Int) = 4
        [HideInInspector][ToggleUI]_RayTracing("Boolean", Float) = 0
        [HideInInspector][Enum(None, 0, Planar, 1, Sphere, 2, Thin, 3)]_RefractionModel("Float", Float) = 0
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="HDRenderPipeline"
            "RenderType"="HDLitShader"
            "Queue"="AlphaTest+25"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="HDLitSubTarget"
        }

        // meta
        Pass
        {
            Name "META"
            Tags{ "LightMode" = "META" }
        
            Cull Off
        
            HLSLPROGRAM
            #define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
            #include "LW_FuncH.hlsl"
            #include "LW_SP_LightTransport.hlsl"
            ENDHLSL
        }
        // shadow
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
        
            Cull [_CullMode]
            ZWrite On
            ColorMask 0
            ZClip [_ZClip]
        
            HLSLPROGRAM
            #define SHADERPASS SHADERPASS_SHADOWS
            #include "LW_FuncH.hlsl"
            #include "LW_SP_DepthAndShadow.hlsl"
            ENDHLSL
        }
        // depth only
        Pass
        {
            Name "DepthOnly"
            Tags{  "LightMode" = "DepthOnly" }
        
            Cull [_CullMode]
            ZWrite On
            Stencil
            {
                WriteMask [_StencilWriteMaskDepth]
                Ref [_StencilRefDepth]
                CompFront Always
                PassFront Replace
                CompBack Always
                PassBack Replace
            }
            AlphaToMask [_AlphaCutoffEnable]
           
        
            HLSLPROGRAM
            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #include "LW_FuncH.hlsl"
            #include "LW_SP_DepthAndShadow.hlsl"
            ENDHLSL
        }
        // gbuffer
        Pass
        {
            Name "GBuffer"
            Tags { "LightMode" = "GBuffer" }
        
            Cull Back
            ZTest [_ZTestGBuffer]
            ColorMask [_LightLayersMaskBuffer4] 4
            ColorMask [_LightLayersMaskBuffer5] 5
            Stencil
            {
                WriteMask [_StencilWriteMaskGBuffer]
                Ref [_StencilRefGBuffer]
                CompFront Always
                PassFront Replace
                CompBack Always
                PassBack Replace
            }
        
            HLSLPROGRAM
            #define SHADERPASS SHADERPASS_GBUFFER
            #include "LW_FuncH.hlsl"
            #include "LW_SP_GBuffer.hlsl"
            ENDHLSL
        }
        // forward
        Pass
        {
            Name "Forward"
            Tags{  "LightMode" = "Forward" }
        
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask [_ColorMaskTransparentVelOne] 1
            ColorMask [_ColorMaskTransparentVelTwo] 2
            Stencil
            {
                WriteMask [_StencilWriteMask]
                Ref [_StencilRef]
                CompFront Always
                PassFront Replace
                CompBack Always
                PassBack Replace
            }
        
            HLSLPROGRAM
            #define SHADERPASS SHADERPASS_FORWARD
            #include "LW_FuncH.hlsl"
            #include "LW_SP_Forward.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "com.graphi.renderhdrp.editor.LongWoolShaderGUI"
    //FallBack "Hidden/Shader Graph/FallbackError"
    FallBack "Hidden/Graphi/FallbackErr"
}