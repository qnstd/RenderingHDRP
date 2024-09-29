Shader "Graphi/Lit/Fur"
{
    Properties
    {
        // lit standard 参数
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

        // fur 参数
        [SingleLine][NoScaleOffset]_FurMap("Fur Map", 2D) = "white" {}
        [SingleLine][NoScaleOffset]_FurNormalMap("FurNormal Map", 2D) = "bump" {}
        [Space(5)]
        _FurNormalForce("Fur NormalForce", float) = 1
        [IntRange] _Length("Length", Range(1, 10)) = 10
        _Step("Step", Range(0.0, 0.01)) = 0.00707
        _Density("Density", Range(0.0, 30.0)) = 10.94
        _Cutoffs("Cutoff", Range(0.0, 1.0)) = 0.139
        _Occlusion("Occlusion", Range(0.0, 1.0)) = 0.937
        [Space(10)]
        _BaseOffset("Base Offset", Vector) = (0.0, 0.0, 0.0, 0.0)
        _WindOffset("Wind Offset", Vector) = (0.2, 0.3, 0.2, 0.0)
        _WindAxisWeight("Wind AxisWeight", Vector) = (0.5, 0.7, 0.9, 0.0)
        _WindForce("Wind Force", float) = 3.0
        _WindDisturbance("Wind Disturbance", float) = 1.0

        [HideInInspector]_EmissionColor("Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_RenderQueueType("Float", Float) = 1
        [HideInInspector][ToggleUI]_AddPrecomputedVelocity("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_DepthOffsetEnable("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_ConservativeDepthOffsetEnable("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_TransparentWritingMotionVec("Boolean", Float) = 0
        [HideInInspector][ToggleUI]_AlphaCutoffEnable("Boolean", Float) = 0
        [HideInInspector]_TransparentSortPriority("_TransparentSortPriority", Float) = 0
        [HideInInspector][ToggleUI]_UseShadowThreshold("Boolean", Float) = 0
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

    HLSLINCLUDE
    #pragma target 4.6
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma multi_compile_instancing
    #pragma instancing_options renderinglayer

    // 渲染程序
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma geometry Geom
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderPipeline"="HDRenderPipeline"
            "RenderType"="HDLitShader"
            "Queue"="Geometry+225"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="HDLitSubTarget"
        }

        //shadowcaster
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
            Cull [_CullMode]
            ZWrite On
            ColorMask 0
            ZClip [_ZClip]
        
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
            #define SHADERPASS SHADERPASS_SHADOWS
            #include "FurH.hlsl"
            ENDHLSL
        }
        //depth only
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
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
        
            
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #include "FurH.hlsl"
            ENDHLSL
        }
        //gbuffer
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "GBuffer"
            }

            Cull [_CullMode]
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
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
            #define SHADERPASS SHADERPASS_GBUFFER
            #include "FurH.hlsl"
            ENDHLSL
        }
        //forward
        Pass
        {
            Name "Forward"
            Tags{ "LightMode" = "Forward"  }
        
            Cull [_CullModeForward]
            Blend [_SrcBlend] [_DstBlend], [_AlphaSrcBlend] [_AlphaDstBlend]
            Blend 1 SrcAlpha OneMinusSrcAlpha
            ZTest [_ZTestDepthEqualForOpaque]
            ZWrite [_ZWrite]
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
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
            #define SHADERPASS SHADERPASS_FORWARD
            #include "FurH.hlsl"
            ENDHLSL
        }
        //meta
        Pass
        {
            Name "META"
            Tags
            {
                "LightMode" = "META"
            }
        
            Cull Off
        
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
            #define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
            #include "FurH.hlsl"
            ENDHLSL
        }
        //motion vector
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
            Cull [_CullMode]
            ZWrite On
            Stencil
            {
                WriteMask [_StencilWriteMaskMV]
                Ref [_StencilRefMV]
                CompFront Always
                PassFront Replace
                CompBack Always
                PassBack Replace
            }
        
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
            #define SHADERPASS SHADERPASS_MOTION_VECTORS
            #include "FurH.hlsl"
            ENDHLSL
        }
    }
   
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "com.graphi.renderhdrp.editor.FurShaderGUI" "UnityEngine.Rendering.HighDefinition.HDRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}