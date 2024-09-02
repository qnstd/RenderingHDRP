/*
    分层渲染着色器
    (由 Graphi 着色器工具自动生成)

    渲染管线：
        High-Definition Render Pipeline

    作者：
        强辰

////////////////////////////////////////////////////////////////////////////////
/// 着色器说明

      △ 纹理说明
        {
            基础纹理（BaseMap、NormalMap）
		        反照率：常规纹理（RGB纹理）
		        法线图：R，G用于存储法线信息（切线空间）。B用于存储金属度，A用于存储平滑度
		

	        混合纹理（MaskMap）
		        R：用于控制分层1的法线、反照率、金属度、平滑度、自发光等数据的融合
		        G: 分层2，功能同上
		        B：分层3，功能同上
		        A：分层4，功能同上

	        分层纹理（BaseMap1-4，NormalMap1-4）
		        反照率：RGBA纹理（TGA类型或PNG类型），其中Alpha通道用于融合，若为PNG类型，Alpha=1
		        法线图：R，G用于存储法线信息（切线空间）。B用于存储金属度，A用于存储平滑度 


	        各纹理类型设置
		        BaseMap，BaseMap1-4
			        纹理类型（Texture Type）: Default
			        sRGB（Color Texture）: √ 勾选 

		        NormalMap，NormalMap1-4
			        纹理类型（Texture Type）：Default
			        sRGB（Color Texture）：□ 取消勾选 
                        1. 由R、G存储的法线信息在采样后不能直接使用，需要将法线信息进行组合后才可执行解包。组合方式：float4(1.0, sample.g, 0.0, sample.r)，组合后再执行 UnpackNormalScale 函数解包；
                        2. B和A存储的金属度和平滑度信息也是线性的，必须将sRGB关闭，否则将数据送进着色器进行计算时会出错，效果不正确；
	
		        MaskMap
			        纹理类型（Texture Type）：Default
			        sRGB（Color Texture）：√ 勾选 或 □ 取消勾选（都可以）因为此遮罩混合图的 RGBA 四个通道的值不是0就是1，最终计算后会将sRGB值转为Linear，建议取消勾选。
        }    

/// 结束
////////////////////////////////////////////////////////////////////////////////

*/
Shader "Graphi/Lit/Layered"
{
    Properties
    {
        // 内置属性
        // 包含渲染类型/队列/混合/Stencil模板等常规内置选项卡。以下内容不允许对其进行任何修改！
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

        // 自定义属性
        // 这里可根据具体效果实现，添加自定义属性
        [Space(10)]
        [HDR]_Color("颜色", Color) =(1,1,1,1)
        _BaseMap("基础纹理", 2D) = "white"{}
        [SingleLine][NoScaleOffset]_NormalMap("法线纹理", 2D) = "bump"{}
        _NormalIntensity("法线强度", float) = 1
        _MetallicIntensity("金属度", Range(0,1)) = 0
        _SmoothnessIntensity("平滑度", Range(0,1)) = 0.5
        [Toggle]_Emission("自发光", float) = 0
        [HDR]_EmissionClr("自发光颜色", Color)=(0,0,0,1)

        [Header(MASK MAP)]
        [Space(8)]
        [SingleLine][NoScaleOffset]_MaskMap("混合贴图", 2D) = "white"{}
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_RChannelUVSelect("R 通道采样UV", int) = 1
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_GChannelUVSelect("G 通道采样UV", int) = 1
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_BChannelUVSelect("B 通道采样UV", int) = 1
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_AChannelUVSelect("A 通道采样UV", int) = 1

        //[Header(AO)]
        //[Space(8)]
        //[Toggle]_AOToggle("开关", float) = 0
        //[Enum(MaskMap R Channel,0,MaskMap G Channel,1,MaskMap B Channel,2,MaskMap A Channel,3)]_AOChannelSelect("通道", int) = 0
        //_AOIntensity("强度", Range(0,2)) = 0

        [Header(LAYER RENDERING _1)]
        [Space(8)]
        [Toggle]_Layer1Toggle("开关", float) = 0
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_Layer1UVSelect("采样UV", int) = 1
        [Enum(Override,1,Multiply,2)]_Layer1BlendModel("混合模式", int) = 1
        [HDR]_Color1("颜色",Color)=(1,1,1,1)
        _BaseMap1("层级1纹理",2D)="white"{}
        [SingleLine][NoScaleOffset]_NormalMap1("法线纹理",2D) = "bump"{}
        _Layer1Alpha("透明度", Range(0,1)) = 1
        _NormalIntensity1("法线强度", float) = 1
        _MetallicIntensity1("金属度",Range(0,1)) = 0
        _SmoothnessIntensity1("平滑度",Range(0,1)) = 0.5
        [Toggle]_Emission1("自发光",float) = 0
        [HDR]_EmissionClr1("自发光颜色",Color)=(0,0,0,1)

        [Header(LAYER RENDERING _2)]
        [Space(8)]
        [Toggle]_Layer2Toggle("开关", float) = 0
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_Layer2UVSelect("采样UV", int) = 1
        [Enum(Override,1,Multiply,2)]_Layer2BlendModel("混合模式", int) = 1
        [HDR]_Color2("颜色",Color)=(1,1,1,1)
        _BaseMap2("层级2纹理",2D)="white"{}
        [SingleLine][NoScaleOffset]_NormalMap2("法线纹理",2D) = "bump"{}
        _Layer2Alpha("透明度", Range(0,1)) = 1
        _NormalIntensity2("法线强度", float) = 1
        _MetallicIntensity2("金属度",Range(0,1)) = 0
        _SmoothnessIntensity2("平滑度",Range(0,1)) = 0.5
        [Toggle]_Emission2("自发光",float) = 0
        [HDR]_EmissionClr2("自发光颜色",Color)=(0,0,0,1)

        [Header(LAYER RENDERING _3)]
        [Space(8)]
        [Toggle]_Layer3Toggle("开关", float) = 0
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_Layer3UVSelect("采样UV", int) = 1
        [Enum(Override,1,Multiply,2)]_Layer3BlendModel("混合模式", int) = 1
        [HDR]_Color3("颜色",Color)=(1,1,1,1)
        _BaseMap3("层级3纹理",2D)="white"{}
        [SingleLine][NoScaleOffset]_NormalMap3("法线纹理",2D) = "bump"{}
        _Layer3Alpha("透明度", Range(0,1)) = 1
        _NormalIntensity3("法线强度", float) = 1
        _MetallicIntensity3("金属度",Range(0,1)) = 0
        _SmoothnessIntensity3("平滑度",Range(0,1)) = 0.5
        [Toggle]_Emission3("自发光",float) = 0
        [HDR]_EmissionClr3("自发光颜色",Color)=(0,0,0,1)

        [Header(LAYER RENDERING _4)]
        [Space(8)]
        [Toggle]_Layer4Toggle("开关", float) = 0
        [Enum(UV1,1,UV2,2,UV3,3,UV4,4)]_Layer4UVSelect("采样UV", int) = 1
        [Enum(Override,1,Multiply,2)]_Layer4BlendModel("混合模式", int) = 1
        [HDR]_Color4("颜色",Color)=(1,1,1,1)
        _BaseMap4("层级4纹理",2D)="white"{}
        [SingleLine][NoScaleOffset]_NormalMap4("法线纹理",2D) = "bump"{}
        _Layer4Alpha("透明度", Range(0,1)) = 1
        _NormalIntensity4("法线强度", float) = 1
        _MetallicIntensity4("金属度",Range(0,1)) = 0
        _SmoothnessIntensity4("平滑度",Range(0,1)) = 0.5
        [Toggle]_Emission4("自发光",float) = 0
        [HDR]_EmissionClr4("自发光颜色",Color)=(0,0,0,1)
        // END
    }


    HLSLINCLUDE
    // 引用包含的必备项
    #include "../HLSL/Graphi-LitInclude.hlsl"

    // SRP 属性
    CBUFFER_START(UnityPerMaterial)
        // 内置属性（不可修改）
        float4 _EmissionColor;
        float _UseShadowThreshold;
        float4 _DoubleSidedConstants;
        float _BlendMode;
        float _EnableBlendModePreserveSpecularLighting;
        float _RayTracing;
        float _RefractionModel;
        
        // ///////////////////////////////////////
        // 以下是自定义属性
        float4 _Color, _EmissionClr, 
        _Color1, _EmissionClr1, 
        _Color2, _EmissionClr2, 
        _Color3, _EmissionClr3, 
        _Color4, _EmissionClr4;

        float4 _BaseMap_ST, _MaskMap_ST, _BaseMap1_ST, _BaseMap2_ST, _BaseMap3_ST, _BaseMap4_ST;

        float _NormalIntensity, _MetallicIntensity, _SmoothnessIntensity, _Emission, 
        //_AOToggle, _AOIntensity,
        _Layer1Toggle, _Layer1Alpha, _NormalIntensity1, _MetallicIntensity1, _SmoothnessIntensity1, _Emission1,
        _Layer2Toggle, _Layer2Alpha, _NormalIntensity2, _MetallicIntensity2, _SmoothnessIntensity2, _Emission2,
        _Layer3Toggle, _Layer3Alpha, _NormalIntensity3, _MetallicIntensity3, _SmoothnessIntensity3, _Emission3,
        _Layer4Toggle, _Layer4Alpha, _NormalIntensity4, _MetallicIntensity4, _SmoothnessIntensity4, _Emission4;

        int _RChannelUVSelect,_GChannelUVSelect,_BChannelUVSelect,_AChannelUVSelect,
        //_AOChannelSelect,
        _Layer1UVSelect, _Layer1BlendModel,
        _Layer2UVSelect, _Layer2BlendModel,
        _Layer3UVSelect, _Layer3BlendModel,
        _Layer4UVSelect, _Layer4BlendModel;
    CBUFFER_END

    // 纹理
    TEXTURE2D(_BaseMap);
    SAMPLER(sampler_BaseMap);
    TEXTURE2D(_NormalMap);
    SAMPLER(sampler_NormalMap);
    TEXTURE2D(_MaskMap);
    SAMPLER(sampler_MaskMap);

    TEXTURE2D(_BaseMap1);
    SAMPLER(sampler_BaseMap1);
    TEXTURE2D(_NormalMap1);
    SAMPLER(sampler_NormalMap1);

    TEXTURE2D(_BaseMap2);
    SAMPLER(sampler_BaseMap2);
    TEXTURE2D(_NormalMap2);
    SAMPLER(sampler_NormalMap2);

    TEXTURE2D(_BaseMap3);
    SAMPLER(sampler_BaseMap3);
    TEXTURE2D(_NormalMap3);
    SAMPLER(sampler_NormalMap3);

    TEXTURE2D(_BaseMap4);
    SAMPLER(sampler_BaseMap4);
    TEXTURE2D(_NormalMap4);
    SAMPLER(sampler_NormalMap4);
    ENDHLSL


    SubShader
    {
        Tags
        {
            "RenderPipeline"="HDRenderPipeline"
            "RenderType"="HDLitShader"
            "Queue"="Geometry+225" //队列（此值不允许被修改）
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="HDLitSubTarget"
        }

// ShadowCaster
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
            #pragma vertex Vert
            #pragma fragment Frag
        
            struct CustomInterpolators
            {
            };
            #define USE_CUSTOMINTERP_SUBSTRUCT
        	#ifdef HAVE_VFX_MODIFICATION
        	struct FragInputsVFX
            {
            };
            #endif
            
            // 定义此通道为投影
            #define SHADERPASS SHADERPASS_SHADOWS
        
            // 需要的顶点属性
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        

            struct AttributesMesh
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct VaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
        
            struct PackedVaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
        
            PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
            {
                PackedVaryingsMeshToPS output;
                ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
            {
                VaryingsMeshToPS output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
        
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            struct SurfaceDescriptionInputs
            {
            };
            struct SurfaceDescription
            {
                float Alpha;
            };
        
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                return surface;
            }
        
        
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES AttributesMesh
            #define VaryingsMeshType VaryingsMeshToPS
            #define VFX_SRP_VARYINGS VaryingsMeshType
            #define VFX_SRP_SURFACE_INPUTS FragInputs
            #endif
            
            VertexDescriptionInputs AttributesMeshToVertexDescriptionInputs(AttributesMesh input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
        
                return output;
            }
        
            VertexDescription GetVertexDescription(AttributesMesh input, float3 timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescriptionInputs vertexDescriptionInputs = AttributesMeshToVertexDescriptionInputs(input);
        
            #ifdef HAVE_VFX_MODIFICATION
                GraphProperties properties;
                ZERO_INITIALIZE(GraphProperties, properties);
                GetElementVertexProperties(element, properties);
                VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs, properties);
            #else
                VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
            #endif
                return vertexDescription;
            }
            
            // 应用网格定义
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters
            #ifdef USE_CUSTOMINTERP_SUBSTRUCT
                #ifdef TESSELLATION_ON
                , inout VaryingsMeshToDS varyings
                #else
                , inout VaryingsMeshToPS varyings
                #endif
            #endif
            #ifdef HAVE_VFX_MODIFICATION
                    , AttributesElement element
            #endif
                )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
                
                // 将顶点描述的位置、法线、切线信息赋值
                input.positionOS = vertexDescription.Position;
                input.normalOS = vertexDescription.Normal;
                input.tangentOS.xyz = vertexDescription.Tangent;
        
                return input;
            }
        
            #if defined(_ADD_CUSTOM_VELOCITY) 
            float3 GetCustomVelocity(AttributesMesh input
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, _TimeParameters.xyz
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
                return vertexDescription.CustomVelocity;
            }
            #endif
        
            // 构建片元输入数据结构
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                output.tangentToWorld = k_identity3x3;
                output.positionSS = input.positionCS; //positionCS : SV_POSITION
        
        
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                #endif
                #endif
        
                return output;
            }
        
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
            #if defined(HAVE_VFX_MODIFICATION) && defined(UNITY_INSTANCING_ENABLED)
                unity_InstanceID = input.instanceID;
            #endif
                VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }
                SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #if defined(SHADER_STAGE_RAY_TRACING)
                #else
                #endif
        
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
        
                return output;
            }
        
           
            // 构建SurfaceData 表面数据结构
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
        
                surfaceData.specularOcclusion = 1.0;
        
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
                surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];
                surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    
        
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
            // 构建 SurfaceData 和 BuiltinData
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
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
        
                #if defined(HAVE_VFX_MODIFICATION)
                GraphProperties properties;
                ZERO_INITIALIZE(GraphProperties, properties);
        
                GetElementPixelProperties(fragInputs, properties);
        
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
                #else
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
                #endif
        
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
        
                #ifdef UNITY_VIRTUAL_TEXTURING
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
        
            
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
        	#ifdef HAVE_VFX_MODIFICATION
        	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/VisualEffectVertex.hlsl"
        	#endif
        
            ENDHLSL
        }
// META
        Pass
        {
            Name "META"
            Tags
            {
                "LightMode" = "META"
            }
            Cull Off
        
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
        
            #pragma shader_feature _ EDITOR_VISUALIZATION
        
        	#ifdef HAVE_VFX_MODIFICATION
        	struct FragInputsVFX
            {
            };
            #endif
            
            // 通道定位光传输
            #define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
        
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_TEXCOORD3

            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_POSITIONPREDISPLACEMENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD3
        
            #define FRAG_INPUTS_USE_TEXCOORD0
            #define FRAG_INPUTS_USE_TEXCOORD1
            #define FRAG_INPUTS_USE_TEXCOORD2
            #define FRAG_INPUTS_USE_TEXCOORD3
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            struct AttributesMesh
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                 float4 uv2 : TEXCOORD2;
                 float4 uv3 : TEXCOORD3;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct VaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float3 positionRWS;
                 float3 positionPredisplacementRWS;
                 float4 texCoord0;
                 float4 texCoord1;
                 float4 texCoord2;
                 float4 texCoord3;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
            struct VertexDescriptionInputs
            {
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
            };
            struct PackedVaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float4 texCoord0 : INTERP0;
                 float4 texCoord1 : INTERP1;
                 float4 texCoord2 : INTERP2;
                 float4 texCoord3 : INTERP3;
                 float3 positionRWS : INTERP4;
                 float3 positionPredisplacementRWS : INTERP5;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
        
            PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
            {
                PackedVaryingsMeshToPS output;
                ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);
                output.positionCS = input.positionCS;
                output.texCoord0.xyzw = input.texCoord0;
                output.texCoord1.xyzw = input.texCoord1;
                output.texCoord2.xyzw = input.texCoord2;
                output.texCoord3.xyzw = input.texCoord3;
                output.positionRWS.xyz = input.positionRWS;
                output.positionPredisplacementRWS.xyz = input.positionPredisplacementRWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
            {
                VaryingsMeshToPS output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.texCoord0.xyzw;
                output.texCoord1 = input.texCoord1.xyzw;
                output.texCoord2 = input.texCoord2.xyzw;
                output.texCoord3 = input.texCoord3.xyzw;
                output.positionRWS = input.positionRWS.xyz;
                output.positionPredisplacementRWS = input.positionPredisplacementRWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
        
            struct VertexDescription
            {
            };
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                return description;
            }
        
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 Emission;
                float Alpha;
                float3 BentNormal;
                float Smoothness;
                float Occlusion;
                float3 NormalTS;
                float Metallic;
            };
        
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                surface.Emission = float3(0, 0, 0);
                surface.Alpha = 1;
                surface.BentNormal = IN.TangentSpaceNormal;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Metallic = 0;
                return surface;
            }
        
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES AttributesMesh
            #define VaryingsMeshType VaryingsMeshToPS
            #define VFX_SRP_VARYINGS VaryingsMeshType
            #define VFX_SRP_SURFACE_INPUTS FragInputs
            #endif
            
            VertexDescriptionInputs AttributesMeshToVertexDescriptionInputs(AttributesMesh input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        
                return output;
            }
        
            VertexDescription GetVertexDescription(AttributesMesh input, float3 timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescriptionInputs vertexDescriptionInputs = AttributesMeshToVertexDescriptionInputs(input);
                #ifdef HAVE_VFX_MODIFICATION
                    GraphProperties properties;
                    ZERO_INITIALIZE(GraphProperties, properties);
                    GetElementVertexProperties(element, properties);
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs, properties);
                #else
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
                #endif
                return vertexDescription;
            }
        
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters
            #ifdef USE_CUSTOMINTERP_SUBSTRUCT
                #ifdef TESSELLATION_ON
                , inout VaryingsMeshToDS varyings
                #else
                , inout VaryingsMeshToPS varyings
                #endif
            #endif
            #ifdef HAVE_VFX_MODIFICATION
                    , AttributesElement element
            #endif
                )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
        
                return input;
            }
        
            #if defined(_ADD_CUSTOM_VELOCITY) // For shader graph custom velocity
            float3 GetCustomVelocity(AttributesMesh input
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, _TimeParameters.xyz
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
                return vertexDescription.CustomVelocity;
            }
            #endif
        
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                output.tangentToWorld = k_identity3x3;
                output.positionSS = input.positionCS;   
        
                output.positionRWS =                input.positionRWS;
                output.positionPredisplacementRWS = input.positionPredisplacementRWS;
                output.texCoord0 =                  input.texCoord0;
                output.texCoord1 =                  input.texCoord1;
                output.texCoord2 =                  input.texCoord2;
                output.texCoord3 =                  input.texCoord3;
        
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                #endif
                #endif
        
                return output;
            }
        
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
            #if defined(HAVE_VFX_MODIFICATION) && defined(UNITY_INSTANCING_ENABLED)
                unity_InstanceID = input.instanceID;
            #endif
                VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }
                SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #if defined(SHADER_STAGE_RAY_TRACING)
                #else
                #endif
                output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
                return output;
            }
        
        
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
        
                surfaceData.specularOcclusion = 1.0;
                surfaceData.baseColor =                 surfaceDescription.BaseColor;
                surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
                surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
                surfaceData.metallic =                  surfaceDescription.Metallic;
        
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
        
                GetNormalWS(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS, doubleSidedConstants);
                surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];
                surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz); 
        
        
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
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
        
                #if defined(HAVE_VFX_MODIFICATION)
                GraphProperties properties;
                ZERO_INITIALIZE(GraphProperties, properties);
        
                GetElementPixelProperties(fragInputs, properties);
        
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
                #else
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
                #endif
        
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
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassLightTransport.hlsl"
        	#ifdef HAVE_VFX_MODIFICATION
        	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/VisualEffectVertex.hlsl"
        	#endif
        
            ENDHLSL
        }
// 深度预处理
        Pass
        {
            Name "TransparentDepthPrepass"
            Tags
            {
                "LightMode" = "TransparentDepthPrepass"
            }
        
            Cull [_CullMode]
            Blend One Zero
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
            #pragma vertex Vert
            #pragma fragment Frag
        
            struct CustomInterpolators
            {
            };
            #define USE_CUSTOMINTERP_SUBSTRUCT
        
        	#ifdef HAVE_VFX_MODIFICATION
        	struct FragInputsVFX
            {
            };
            #endif
        
        
            // 通道定义为深度预处理
            #define SHADERPASS SHADERPASS_TRANSPARENT_DEPTH_PREPASS

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_TANGENT_TO_WORLD
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        

            struct AttributesMesh
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct VaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 tangentWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
            };
            struct PackedVaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float4 tangentWS : INTERP0;
                 float3 normalWS : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
        
            PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
            {
                PackedVaryingsMeshToPS output;
                ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);
                output.positionCS = input.positionCS;
                output.tangentWS.xyzw = input.tangentWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
            {
                VaryingsMeshToPS output;
                output.positionCS = input.positionCS;
                output.tangentWS = input.tangentWS.xyzw;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
            struct SurfaceDescription
            {
                float Alpha;
                float3 NormalTS;
                float Smoothness;
            };
        
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Smoothness = 0.5;
                return surface;
            }
        
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES AttributesMesh
            #define VaryingsMeshType VaryingsMeshToPS
            #define VFX_SRP_VARYINGS VaryingsMeshType
            #define VFX_SRP_SURFACE_INPUTS FragInputs
            #endif
            
            VertexDescriptionInputs AttributesMeshToVertexDescriptionInputs(AttributesMesh input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
        
                return output;
            }
        
            VertexDescription GetVertexDescription(AttributesMesh input, float3 timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescriptionInputs vertexDescriptionInputs = AttributesMeshToVertexDescriptionInputs(input);
        
                #ifdef HAVE_VFX_MODIFICATION
                    GraphProperties properties;
                    ZERO_INITIALIZE(GraphProperties, properties);
        
                    GetElementVertexProperties(element, properties);
        
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs, properties);
                #else
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
                #endif
                return vertexDescription;
            }
        
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters
            #ifdef USE_CUSTOMINTERP_SUBSTRUCT
                #ifdef TESSELLATION_ON
                , inout VaryingsMeshToDS varyings
                #else
                , inout VaryingsMeshToPS varyings
                #endif
            #endif
            #ifdef HAVE_VFX_MODIFICATION
                    , AttributesElement element
            #endif
                )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
        
                input.positionOS = vertexDescription.Position;
                input.normalOS = vertexDescription.Normal;
                input.tangentOS.xyz = vertexDescription.Tangent;
        
                return input;
            }
        
            #if defined(_ADD_CUSTOM_VELOCITY) // For shader graph custom velocity
            float3 GetCustomVelocity(AttributesMesh input
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, _TimeParameters.xyz
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
                return vertexDescription.CustomVelocity;
            }
            #endif
        
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                output.tangentToWorld = k_identity3x3;
                output.positionSS = input.positionCS;  
        
                output.tangentToWorld =             BuildTangentToWorld(input.tangentWS, input.normalWS);
        
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                #endif
                #endif
                return output;
            }
        
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
            #if defined(HAVE_VFX_MODIFICATION) && defined(UNITY_INSTANCING_ENABLED)
                unity_InstanceID = input.instanceID;
            #endif
                VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }
                SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #if defined(SHADER_STAGE_RAY_TRACING)
                #else
                #endif
                output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
        
                return output;
            }
        
            
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
            
                surfaceData.specularOcclusion = 1.0;
                surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
        
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
        
                GetNormalWS(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS, doubleSidedConstants);
                surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];
                surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);  
        
        
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
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
        
                #if defined(HAVE_VFX_MODIFICATION)
                GraphProperties properties;
                ZERO_INITIALIZE(GraphProperties, properties);
        
                GetElementPixelProperties(fragInputs, properties);
        
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
                #else
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
                #endif
        
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
        
                #ifdef UNITY_VIRTUAL_TEXTURING
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
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
        	#ifdef HAVE_VFX_MODIFICATION
        	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/VisualEffectVertex.hlsl"
        	#endif
        
            ENDHLSL
        }
// 深度
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
            #pragma vertex Vert
            #pragma fragment Frag
        
            #pragma multi_compile _ WRITE_NORMAL_BUFFER
            #pragma multi_compile_fragment _ WRITE_MSAA_DEPTH
            #pragma multi_compile _ WRITE_DECAL_BUFFER
        
            
            struct CustomInterpolators
            {
            };
            #define USE_CUSTOMINTERP_SUBSTRUCT
        	#ifdef HAVE_VFX_MODIFICATION
        	struct FragInputsVFX
            {
            };
            #endif
            
            // 通道定义为深度
            #define SHADERPASS SHADERPASS_DEPTH_ONLY
        
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_TANGENT_TO_WORLD
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        

            struct AttributesMesh
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct VaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 tangentWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
            };
            struct PackedVaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float4 tangentWS : INTERP0;
                 float3 normalWS : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
        
            PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
            {
                PackedVaryingsMeshToPS output;
                ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);
                output.positionCS = input.positionCS;
                output.tangentWS.xyzw = input.tangentWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
            {
                VaryingsMeshToPS output;
                output.positionCS = input.positionCS;
                output.tangentWS = input.tangentWS.xyzw;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 Emission;
                float Alpha;
                float3 BentNormal;
                float Smoothness;
                float Occlusion;
                float3 NormalTS;
                float Metallic;
            };
        
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                surface.Emission = float3(0, 0, 0);
                surface.Alpha = 1;
                surface.BentNormal = IN.TangentSpaceNormal;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Metallic = 0;
                return surface;
            }
        
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES AttributesMesh
            #define VaryingsMeshType VaryingsMeshToPS
            #define VFX_SRP_VARYINGS VaryingsMeshType
            #define VFX_SRP_SURFACE_INPUTS FragInputs
            #endif
            
            VertexDescriptionInputs AttributesMeshToVertexDescriptionInputs(AttributesMesh input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
        
                return output;
            }
        
            VertexDescription GetVertexDescription(AttributesMesh input, float3 timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescriptionInputs vertexDescriptionInputs = AttributesMeshToVertexDescriptionInputs(input);
                #ifdef HAVE_VFX_MODIFICATION
                    GraphProperties properties;
                    ZERO_INITIALIZE(GraphProperties, properties);
                    GetElementVertexProperties(element, properties);
        
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs, properties);
                #else
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
                #endif
                return vertexDescription;
            }
        
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters
            #ifdef USE_CUSTOMINTERP_SUBSTRUCT
                #ifdef TESSELLATION_ON
                , inout VaryingsMeshToDS varyings
                #else
                , inout VaryingsMeshToPS varyings
                #endif
            #endif
            #ifdef HAVE_VFX_MODIFICATION
                    , AttributesElement element
            #endif
                )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
        
                input.positionOS = vertexDescription.Position;
                input.normalOS = vertexDescription.Normal;
                input.tangentOS.xyz = vertexDescription.Tangent;
        
                return input;
            }
        
            #if defined(_ADD_CUSTOM_VELOCITY) // For shader graph custom velocity
            float3 GetCustomVelocity(AttributesMesh input
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, _TimeParameters.xyz
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
                return vertexDescription.CustomVelocity;
            }
            #endif
        
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                output.tangentToWorld = k_identity3x3;
                output.positionSS = input.positionCS;
        
                output.tangentToWorld =             BuildTangentToWorld(input.tangentWS, input.normalWS);
        
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                #endif
                #endif
        
                return output;
            }
        
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
            #if defined(HAVE_VFX_MODIFICATION) && defined(UNITY_INSTANCING_ENABLED)
                unity_InstanceID = input.instanceID;
            #endif
                VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }

            SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #if defined(SHADER_STAGE_RAY_TRACING)
                #else
                #endif
                output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
                return output;
            }
        
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
        
                surfaceData.specularOcclusion = 1.0;
                surfaceData.baseColor =                 surfaceDescription.BaseColor;
                surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
                surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
                surfaceData.metallic =                  surfaceDescription.Metallic;
        
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
        
                GetNormalWS(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS, doubleSidedConstants);
                surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];
                surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz); 
        
        
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
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
        
                #if defined(HAVE_VFX_MODIFICATION)
                GraphProperties properties;
                ZERO_INITIALIZE(GraphProperties, properties);
        
                GetElementPixelProperties(fragInputs, properties);
        
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
                #else
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
                #endif
        
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
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"
        	#ifdef HAVE_VFX_MODIFICATION
        	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/VisualEffectVertex.hlsl"
        	#endif
        
            ENDHLSL
        }
// GBuffer
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
            #pragma vertex Vert
            #pragma fragment Frag
        
            #pragma multi_compile_fragment _ LIGHT_LAYERS
            #pragma multi_compile_raytracing _ LIGHT_LAYERS
            #pragma multi_compile _ DEBUG_DISPLAY
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile_fragment PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
            #pragma multi_compile_raytracing PROBE_VOLUMES_OFF PROBE_VOLUMES_L1 PROBE_VOLUMES_L2
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
            #pragma multi_compile_raytracing _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment DECALS_OFF DECALS_3RT DECALS_4RT
            #pragma multi_compile_fragment _ DECAL_SURFACE_GRADIENT
           
            struct CustomInterpolators
            {
            };
            #define USE_CUSTOMINTERP_SUBSTRUCT
        	#ifdef HAVE_VFX_MODIFICATION
        	struct FragInputsVFX
            {
            };
            #endif
        
            // 通道定义为GBuffer
            #define SHADERPASS SHADERPASS_GBUFFER
        
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2

            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            
            #define FRAG_INPUTS_USE_TEXCOORD1
            #define FRAG_INPUTS_USE_TEXCOORD2
            
            // Include 文件
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        
            struct AttributesMesh
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv1 : TEXCOORD1;
                 float4 uv2 : TEXCOORD2;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct VaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float3 positionRWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord1;
                 float4 texCoord2;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
            };
            struct PackedVaryingsMeshToPS
            {
                SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
                 float4 tangentWS : INTERP0;
                 float4 texCoord1 : INTERP1;
                 float4 texCoord2 : INTERP2;
                 float3 positionRWS : INTERP3;
                 float3 normalWS : INTERP4;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
            };
        
            PackedVaryingsMeshToPS PackVaryingsMeshToPS (VaryingsMeshToPS input)
            {
                PackedVaryingsMeshToPS output;
                ZERO_INITIALIZE(PackedVaryingsMeshToPS, output);
                output.positionCS = input.positionCS;
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord1.xyzw = input.texCoord1;
                output.texCoord2.xyzw = input.texCoord2;
                output.positionRWS.xyz = input.positionRWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            VaryingsMeshToPS UnpackVaryingsMeshToPS (PackedVaryingsMeshToPS input)
            {
                VaryingsMeshToPS output;
                output.positionCS = input.positionCS;
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord1 = input.texCoord1.xyzw;
                output.texCoord2 = input.texCoord2.xyzw;
                output.positionRWS = input.positionRWS.xyz;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                return output;
            }
        
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
           
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 Emission;
                float Alpha;
                float3 BentNormal;
                float Smoothness;
                float Occlusion;
                float3 NormalTS;
                float Metallic;
                float4 VTPackedFeedback;
            };
        
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                surface.Emission = float3(0, 0, 0);
                surface.Alpha = 1;
                surface.BentNormal = IN.TangentSpaceNormal;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Metallic = 0;
                {
                    surface.VTPackedFeedback = float4(1.0f,1.0f,1.0f,1.0f);
                }
                return surface;
            }
        
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES AttributesMesh
            #define VaryingsMeshType VaryingsMeshToPS
            #define VFX_SRP_VARYINGS VaryingsMeshType
            #define VFX_SRP_SURFACE_INPUTS FragInputs
            #endif
            
            VertexDescriptionInputs AttributesMeshToVertexDescriptionInputs(AttributesMesh input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
        
                return output;
            }
        
            VertexDescription GetVertexDescription(AttributesMesh input, float3 timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescriptionInputs vertexDescriptionInputs = AttributesMeshToVertexDescriptionInputs(input);
        
                #ifdef HAVE_VFX_MODIFICATION
                    GraphProperties properties;
                    ZERO_INITIALIZE(GraphProperties, properties);
                    GetElementVertexProperties(element, properties);
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs, properties);
                #else
                    VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
                #endif

                return vertexDescription;
            }
        
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters
            #ifdef USE_CUSTOMINTERP_SUBSTRUCT
                #ifdef TESSELLATION_ON
                , inout VaryingsMeshToDS varyings
                #else
                , inout VaryingsMeshToPS varyings
                #endif
            #endif
            #ifdef HAVE_VFX_MODIFICATION
                    , AttributesElement element
            #endif
                )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
        
                input.positionOS = vertexDescription.Position;
                input.normalOS = vertexDescription.Normal;
                input.tangentOS.xyz = vertexDescription.Tangent;
        
                return input;
            }
        
            #if defined(_ADD_CUSTOM_VELOCITY) // For shader graph custom velocity
            float3 GetCustomVelocity(AttributesMesh input
            #ifdef HAVE_VFX_MODIFICATION
                , AttributesElement element
            #endif
            )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, _TimeParameters.xyz
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
                return vertexDescription.CustomVelocity;
            }
            #endif
        
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                output.tangentToWorld = k_identity3x3;
                output.positionSS = input.positionCS; 
        
                output.positionRWS =                input.positionRWS;
                output.tangentToWorld =             BuildTangentToWorld(input.tangentWS, input.normalWS);
                output.texCoord1 =                  input.texCoord1;
                output.texCoord2 =                  input.texCoord2;
        
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                #endif
                #endif
        
                return output;
            }
        
            FragInputs UnpackVaryingsMeshToFragInputs(PackedVaryingsMeshToPS input)
            {
                UNITY_SETUP_INSTANCE_ID(input);
            #if defined(HAVE_VFX_MODIFICATION) && defined(UNITY_INSTANCING_ENABLED)
                unity_InstanceID = input.instanceID;
            #endif
                VaryingsMeshToPS unpacked = UnpackVaryingsMeshToPS(input);
                return BuildFragInputs(unpacked);
            }

            SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #if defined(SHADER_STAGE_RAY_TRACING)
                #else
                #endif
                output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
        
                return output;
            }
        
        
            void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
        
                surfaceData.specularOcclusion = 1.0;
        
                surfaceData.baseColor =                 surfaceDescription.BaseColor;
                surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
                surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
                surfaceData.metallic =                  surfaceDescription.Metallic;
        
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
        
                GetNormalWS(fragInputs, surfaceDescription.NormalTS, surfaceData.normalWS, doubleSidedConstants);
                surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];
                surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);
        
        
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
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
        
                #if defined(HAVE_VFX_MODIFICATION)
                GraphProperties properties;
                ZERO_INITIALIZE(GraphProperties, properties);
        
                GetElementPixelProperties(fragInputs, properties);
        
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
                #else
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
                #endif
        
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
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassGBuffer.hlsl"
        	#ifdef HAVE_VFX_MODIFICATION
        	#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/VisualEffectVertex.hlsl"
        	#endif
            ENDHLSL
        }
// Forward（主要的图形处理在这里进行操作）
        Pass
        {
            Name "Forward"
            Tags {  "LightMode" = "Forward" }
            
            // 渲染选项卡
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
            // 定义通道为Forward前向渲染通道
            #define SHADERPASS SHADERPASS_FORWARD
        
            // 关键字、变体
            #pragma multi_compile _ DEBUG_DISPLAY
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
           
            struct CustomInterpolators
            {
            };
            #define USE_CUSTOMINTERP_SUBSTRUCT
        	#ifdef HAVE_VFX_MODIFICATION
        	struct FragInputsVFX
            {
            };
            #endif
        
            
            // 光照前向渲染计算需要的数据结构及相关文件引用
            #include "../HLSL/Graphi-LitVaryMeshVertex-Forward.hlsl"
            #include "../HLSL/Graphi-BlendNormal.hlsl"
        	
            // /////////////////////////////////////////////////////////////////
            // 在此函数内实现、并编写自定义的顶点变换（例如：顶点动画等）
            // ///
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters
            #ifdef USE_CUSTOMINTERP_SUBSTRUCT
                #ifdef TESSELLATION_ON
                , inout VaryingsMeshToDS varyings
                #else
                , inout VaryingsMeshToPS varyings
                #endif
            #endif
            #ifdef HAVE_VFX_MODIFICATION
                    , AttributesElement element
            #endif
                )
            {
                VertexDescription vertexDescription = GetVertexDescription(input, timeParameters
            #ifdef HAVE_VFX_MODIFICATION
                    , element
            #endif
                );
        
                input.positionOS = vertexDescription.Position;
                input.normalOS = vertexDescription.Normal;
                input.tangentOS.xyz = vertexDescription.Tangent;

                //TODO： 顶点变换
                // ...
                //TODO： 结束
        
                return input;
            }
            // ///
            // 结束
            // /////////////////////////////////////////////////////////////////

            
            // 构建 Fragment 片元输入的数据结构
            FragInputs BuildFragInputs(VaryingsMeshToPS input)
            {
                FragInputs output;
                ZERO_INITIALIZE(FragInputs, output);
        
                output.tangentToWorld   = k_identity3x3;
                output.positionSS       = input.positionCS;   //positionCS 是 SV_Position 语义类型
                output.positionRWS      = input.positionRWS;
                output.tangentToWorld   = BuildTangentToWorld(input.tangentWS, input.normalWS);
                output.texCoord0        = input.texCoord0;
                output.texCoord1        = input.texCoord1;
                output.texCoord2        = input.texCoord2;
                output.texCoord3        = input.texCoord3;
                output.color            = input.color;
        
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                #endif
                #endif

                return output;
            }

            struct SurfaceDescriptionInputs
            {// 用于计算最终表面数据的SDI数据结构

                 float3 TangentSpaceNormal; // 切线空间的法线
                 float4 uv0;                // 第1套UV
                 float4 uv1;                // 第2套UV
                 float4 uv2;                // 第3套UV
                 float4 uv3;                // 第4套UV
                 float3 viewWS;             // 相对于摄像机的视角方向（归一化Normalize）
                 float3x3 tangentToWorld;   // 切线到世界空间的变换矩阵（0：切线，1：副法线，2：法线）
                 float4 vertexColor;        // 顶点颜色
                 float isFrontFace;         // 是否是正面
            };

            // 当进入片元着色渲染时，FragInputs就是片元数据输入对象。将所需的数据传递给表面描述信息输入结构用于后续计算。
            SurfaceDescriptionInputs FragInputsToSurfaceDescriptionInputs(FragInputs input, float3 viewWS)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #if defined(SHADER_STAGE_RAY_TRACING)
                #else
                #endif
                
                // UV 坐标兼容
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
        
                // 拼接点，用于将片元输入自定义插值器包复制到SDI中
                output.TangentSpaceNormal   = float3(0.0f, 0.0f, 1.0f);
                output.uv0                  = input.texCoord0;  // 第1套UV
                output.uv1                  = input.texCoord1;  // 第2套UV
                output.uv2                  = input.texCoord2;  // 第3套UV
                output.uv3                  = input.texCoord3;  // 第4套UV
                output.viewWS               = viewWS;           // normalize 归一化
                output.tangentToWorld       = input.tangentToWorld; //切线转世界空间矩阵
                output.vertexColor          = input.color; // 顶点颜色
                #ifndef SHADER_UNLIT
                    #if defined(_DOUBLESIDED_ON) && defined(VARYINGS_NEED_CULLFACE)
                        output.isFrontFace = input.isFrontFace ? 1 : -1; // 是否是正面
                    #endif
                #endif
                // 结束
        
                return output;
            }

            struct SurfaceDescription
            {//最终用于计算BRDF光照的表面数据结构

                float3 BaseColor;   // 反照率（基础色）
                float3 Emission;    // 自发光
                float Alpha;        // 透明度
                float Occlusion;    // 剔除、遮蔽
                float3 BentNormal;  // 副法线
                float3 NormalTS;    // 法线（切线空间）
                float Smoothness;   // 平滑度
                float Metallic;     // 金属度
                float4 VTPackedFeedback;
                //float AlphaClipThreshold;
                //float AlphaClipThresholdDepthPostpass;
                //float DepthOffset;
                //float Distortion;
                //float DistortionBlur;
            };

            // ///////////////////////////////////////////////////////////////////
            // 在此函数内编写表面数据信息，用于后续的BRDF计算。
            // 例如：可对纹理属性进行采样、计算等操作。
            // ////
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                // Normal 法线计算
                float2 uv_BaseMap = TRANSFORM_TEX(IN.uv0.xy, _BaseMap);
                float4 sample_NormalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv_BaseMap);
                float4 N_NormalMap = float4(1.0, sample_NormalMap.g, 0.0, sample_NormalMap.r);
                float3 n = UnpackNormalScale(N_NormalMap, _NormalIntensity); // 基础法线

                float2 uv0_MaskMap = TRANSFORM_TEX(IN.uv0.xy, _MaskMap);
                float2 uv1_MaskMap = TRANSFORM_TEX(IN.uv1.xy, _MaskMap);
                float2 uv2_MaskMap = TRANSFORM_TEX(IN.uv2.xy, _MaskMap);
                float2 uv3_MaskMap = TRANSFORM_TEX(IN.uv3.xy, _MaskMap);

                float2 uv0_BaseMap1 = TRANSFORM_TEX(IN.uv0.xy, _BaseMap1);
                float2 uv1_BaseMap1 = TRANSFORM_TEX(IN.uv1.xy, _BaseMap1);
                float2 uv2_BaseMap1 = TRANSFORM_TEX(IN.uv2.xy, _BaseMap1);
                float2 uv3_BaseMap1 = TRANSFORM_TEX(IN.uv3.xy, _BaseMap1);
                float2 uv_BaseMap1 = ((( 4.0 == (float)_Layer1UVSelect ) ? uv3_BaseMap1 :  (( 3.0 == (float)_Layer1UVSelect ) ? uv2_BaseMap1 :  (( 2.0 == (float)_Layer1UVSelect ) ? uv1_BaseMap1 :  (( 1.0 == (float)_Layer1UVSelect ) ? uv0_BaseMap1 :  float2( 0,0 ))))));
                float4 sample_NormalMap1 = SAMPLE_TEXTURE2D(_NormalMap1, sampler_NormalMap1, uv_BaseMap1);
                float4 N_NormalMap1 = float4(1.0, sample_NormalMap1.g, 0.0, sample_NormalMap1.r);
                float3 n1 = UnpackNormalScale(N_NormalMap1, _NormalIntensity1); // 层1法线
                float2 uv_MaskMap_R = (4.0 == (float)_RChannelUVSelect) ? uv3_MaskMap : ((3.0 == (float)_RChannelUVSelect) ? uv2_MaskMap : ((2.0 == (float)_RChannelUVSelect) ? uv1_MaskMap : ((1.0 == (float)_RChannelUVSelect) ? uv0_MaskMap : float2(0,0))));
                float R_MaskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv_MaskMap_R).r; // 混合图R通道值（用于对层1的法线进行遮罩）
                float4 sample_BaseMap1 = SAMPLE_TEXTURE2D(_BaseMap1, sampler_BaseMap1, uv_BaseMap1);
                float Alpha_Sample_BaseMap1 = sample_BaseMap1.a;
                float Clamp_Alpha_Sample_BaseMap1 = clamp(Alpha_Sample_BaseMap1 * 2.0, 0.0, 1.0);
                float lerpval = R_MaskMap * Clamp_Alpha_Sample_BaseMap1; //遮罩值 * 层1反照率的alpha值 = 混合因子
                float3 temp1 = lerp(n, n1, lerpval);
                float3 temp2 = lerp(float3(0,0,1), n1, lerpval);
                float3 blend_N1 = (( 1.0 == (float)(int)_Layer1Toggle ) ? (( 1.0 == (float)_Layer1BlendModel ) ? temp1 :  BlendNormal_RNM2( n , temp2 ) ) :  n ); //混合N1法线

                float2 uv0_BaseMap2 = TRANSFORM_TEX(IN.uv0.xy, _BaseMap2);
                float2 uv1_BaseMap2 = TRANSFORM_TEX(IN.uv1.xy, _BaseMap2);
                float2 uv2_BaseMap2 = TRANSFORM_TEX(IN.uv2.xy, _BaseMap2);
                float2 uv3_BaseMap2 = TRANSFORM_TEX(IN.uv3.xy, _BaseMap2);
                float2 uv_BaseMap2 = ((( 4.0 == (float)_Layer2UVSelect ) ? uv3_BaseMap2 :  (( 3.0 == (float)_Layer2UVSelect ) ? uv2_BaseMap2 :  (( 2.0 == (float)_Layer2UVSelect ) ? uv1_BaseMap2 :  (( 1.0 == (float)_Layer2UVSelect ) ? uv0_BaseMap2 :  float2( 0,0 ))))));
                float4 sample_NormalMap2 = SAMPLE_TEXTURE2D(_NormalMap2, sampler_NormalMap2, uv_BaseMap2);
                float4 N_NormalMap2 = float4(1.0, sample_NormalMap2.g, 0.0, sample_NormalMap2.r);
                float3 n2 = UnpackNormalScale(N_NormalMap2, _NormalIntensity2); // 层2法线
                float2 uv_MaskMap_G = (4.0 == (float)_GChannelUVSelect) ? uv3_MaskMap : ((3.0 == (float)_GChannelUVSelect) ? uv2_MaskMap : ((2.0 == (float)_GChannelUVSelect) ? uv1_MaskMap : ((1.0 == (float)_GChannelUVSelect) ? uv0_MaskMap : float2(0,0))));
                float G_MaskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv_MaskMap_G).g; //混合图G通道（用于对层2的法线进行遮罩）
                float4 sample_BaseMap2 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, uv_BaseMap2);
                float Alpha_Sample_BaseMap2 = sample_BaseMap2.a;
                float Clamp_Alpha_Sample_BaseMap2 = clamp(Alpha_Sample_BaseMap2 * 2.0, 0.0, 1.0);
                lerpval = G_MaskMap * Clamp_Alpha_Sample_BaseMap2; //遮罩值 * 层2反照率的alpha值 = 混合因子
                temp1 = lerp(blend_N1, n2, lerpval);
                temp2 = lerp(float3(0,0,1), n2, lerpval);
                float3 blend_N2 = (( 1.0 == (float)(int)_Layer2Toggle ) ? (( 1.0 == (float)_Layer2BlendModel ) ? temp1 :  BlendNormal_RNM2( blend_N1 , temp2 ) ) :  blend_N1 ); //混合N2法线

                float2 uv0_BaseMap3 = TRANSFORM_TEX(IN.uv0.xy, _BaseMap3);
                float2 uv1_BaseMap3 = TRANSFORM_TEX(IN.uv1.xy, _BaseMap3);
                float2 uv2_BaseMap3 = TRANSFORM_TEX(IN.uv2.xy, _BaseMap3);
                float2 uv3_BaseMap3 = TRANSFORM_TEX(IN.uv3.xy, _BaseMap3);
                float2 uv_BaseMap3 = ((( 4.0 == (float)_Layer3UVSelect ) ? uv3_BaseMap3 :  (( 3.0 == (float)_Layer3UVSelect ) ? uv2_BaseMap3 :  (( 2.0 == (float)_Layer3UVSelect ) ? uv1_BaseMap3 :  (( 1.0 == (float)_Layer3UVSelect ) ? uv0_BaseMap3 :  float2( 0,0 ))))));
                float4 sample_NormalMap3 = SAMPLE_TEXTURE2D(_NormalMap3, sampler_NormalMap3, uv_BaseMap3);
                float4 N_NormalMap3 = float4(1.0, sample_NormalMap3.g, 0.0, sample_NormalMap3.r);
                float3 n3 = UnpackNormalScale(N_NormalMap3, _NormalIntensity3); // 层3法线
                float2 uv_MaskMap_B = (4.0 == (float)_BChannelUVSelect) ? uv3_MaskMap : ((3.0 == (float)_BChannelUVSelect) ? uv2_MaskMap : ((2.0 == (float)_BChannelUVSelect) ? uv1_MaskMap : ((1.0 == (float)_BChannelUVSelect) ? uv0_MaskMap : float2(0,0))));
                float B_MaskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv_MaskMap_B).b; //混合图B通道（用于对层3的法线进行遮罩）
                float4 sample_BaseMap3 = SAMPLE_TEXTURE2D(_BaseMap3, sampler_BaseMap3, uv_BaseMap3);
                float Alpha_Sample_BaseMap3 = sample_BaseMap3.a;
                float Clamp_Alpha_Sample_BaseMap3 = clamp(Alpha_Sample_BaseMap3 * 2.0, 0.0, 1.0);
                lerpval = B_MaskMap * Clamp_Alpha_Sample_BaseMap3; //遮罩值 * 层3反照率的alpha值 = 混合因子
                temp1 = lerp(blend_N2, n3, lerpval);
                temp2 = lerp(float3(0,0,1), n3, lerpval);
                float3 blend_N3 = (( 1.0 == (float)(int)_Layer3Toggle ) ? (( 1.0 == (float)_Layer3BlendModel ) ? temp1 :  BlendNormal_RNM2( blend_N2 , temp2 ) ) :  blend_N2 ); //混合N3法线

                float2 uv0_BaseMap4 = TRANSFORM_TEX(IN.uv0.xy, _BaseMap4);
                float2 uv1_BaseMap4 = TRANSFORM_TEX(IN.uv1.xy, _BaseMap4);
                float2 uv2_BaseMap4 = TRANSFORM_TEX(IN.uv2.xy, _BaseMap4);
                float2 uv3_BaseMap4 = TRANSFORM_TEX(IN.uv3.xy, _BaseMap4);
                float2 uv_BaseMap4 = ((( 4.0 == (float)_Layer4UVSelect ) ? uv3_BaseMap4 :  (( 3.0 == (float)_Layer4UVSelect ) ? uv2_BaseMap4 :  (( 2.0 == (float)_Layer4UVSelect ) ? uv1_BaseMap4 :  (( 1.0 == (float)_Layer4UVSelect ) ? uv0_BaseMap4 :  float2( 0,0 ))))));
                float4 sample_NormalMap4 = SAMPLE_TEXTURE2D(_NormalMap4, sampler_NormalMap4, uv_BaseMap4);
                float4 N_NormalMap4 = float4(1.0, sample_NormalMap4.g, 0.0, sample_NormalMap4.r); 
                float3 n4 = UnpackNormalScale(N_NormalMap4, _NormalIntensity4); // 层4法线
                float2 uv_MaskMap_A = (4.0 == (float)_AChannelUVSelect) ? uv3_MaskMap : ((3.0 == (float)_AChannelUVSelect) ? uv2_MaskMap : ((2.0 == (float)_AChannelUVSelect) ? uv1_MaskMap : ((1.0 == (float)_AChannelUVSelect) ? uv0_MaskMap : float2(0,0))));
                float A_MaskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv_MaskMap_A).a; //混合图A通道（用于对层4的法线进行遮罩）
                float4 sample_BaseMap4 = SAMPLE_TEXTURE2D(_BaseMap4, sampler_BaseMap4, uv_BaseMap4);
                float Alpha_Sample_BaseMap4 = sample_BaseMap4.a;
                float Clamp_Alpha_Sample_BaseMap4 = clamp(Alpha_Sample_BaseMap4 * 2.0, 0.0, 1.0);
                lerpval = A_MaskMap * Clamp_Alpha_Sample_BaseMap4; //遮罩值 * 层4反照率的alpha值 = 混合因子
                temp1 = lerp(blend_N3, n4, lerpval);
                temp2 = lerp(float3(0,0,1), n4, lerpval);
                float3 blend_N4 = (( 1.0 == (float)(int)_Layer4Toggle ) ? (( 1.0 == (float)_Layer4BlendModel ) ? temp1 :  BlendNormal_RNM2( blend_N3 , temp2 ) ) :  blend_N3 ); //混合N4法线
                float3 normalTS = blend_N4; //得到最终的法线（切线空间）

                // 反照率
                float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv_BaseMap);
                float4 albedoColor = albedo * _Color;
                float4 albedo1Color = sample_BaseMap1 * _Color1;
                float lerpAlpha = Clamp_Alpha_Sample_BaseMap1 * _Layer1Alpha * R_MaskMap;
                float4 albedo_temp1 = lerp(albedoColor, albedo1Color, lerpAlpha);
                float4 albedo_temp2 = lerp(albedoColor, albedoColor * albedo1Color * clamp(_Layer1Alpha, 1.0, 2.0) * 4.599, lerpAlpha);
                float4 blend_albedo1 = (( 1.0 == (float)(int)_Layer1Toggle ) ? (( 1.0 == (float)_Layer1BlendModel ) ? albedo_temp1 :  albedo_temp2 ) :  albedoColor);

                float4 albedo2 = sample_BaseMap2 * _Color2;
                lerpAlpha = Clamp_Alpha_Sample_BaseMap2 * _Layer2Alpha * G_MaskMap;
                albedo_temp1 = lerp(blend_albedo1, albedo2, lerpAlpha);
                albedo_temp2 = lerp(blend_albedo1, blend_albedo1 * albedo2 * clamp(_Layer2Alpha, 1.0, 2.0) * 4.599, lerpAlpha);
                float4 blend_albedo2 = (( 1.0 == (float)(int)_Layer2Toggle ) ? (( 1.0 == (float)_Layer2BlendModel ) ? albedo_temp1 :  albedo_temp2 ) :  blend_albedo1);

                float4 albedo3 = sample_BaseMap3 * _Color3;
                lerpAlpha = Clamp_Alpha_Sample_BaseMap3 * _Layer3Alpha * B_MaskMap;
                albedo_temp1 = lerp(blend_albedo2, albedo3, lerpAlpha);
                albedo_temp2 = lerp(blend_albedo2, blend_albedo2 * albedo3 * clamp(_Layer3Alpha, 1.0, 2.0) * 4.599, lerpAlpha);
                float4 blend_albedo3 = (( 1.0 == (float)(int)_Layer3Toggle ) ? (( 1.0 == (float)_Layer3BlendModel ) ? albedo_temp1 :  albedo_temp2 ) :  blend_albedo2);

                float4 albedo4 = sample_BaseMap4 * _Color4;
                lerpAlpha = Clamp_Alpha_Sample_BaseMap4 * _Layer4Alpha * A_MaskMap;
                albedo_temp1 = lerp(blend_albedo3, albedo4, lerpAlpha);
                albedo_temp2 = lerp(blend_albedo3, blend_albedo3 * albedo4 * clamp(_Layer4Alpha, 1.0, 2.0) * 4.599, lerpAlpha);
                float4 blend_albedo4 = (( 1.0 == (float)(int)_Layer4Toggle ) ? (( 1.0 == (float)_Layer4BlendModel ) ? albedo_temp1 :  albedo_temp2 ) :  blend_albedo3);
                float4 baseColor = blend_albedo4; //基础颜色

                // 自发光
                float baseEmissFactor = clamp(1.0 - (1.0 - albedo.a) * 2.1, 0.0, 1.0); // 当反照率的alpha值<=0.5时，则返回0；>0.5时，则返回0-1的值；
                float4 baseEmiss = albedo * baseEmissFactor * _EmissionClr * _Emission; // 基础纹理的自发光颜色

                float emissFactor1 = clamp(1.0 - (1.0 - sample_BaseMap1.a) * 2.1, 0.0, 1.0); 
                float4 emiss1 = sample_BaseMap1 * emissFactor1 * _EmissionClr1 * _Emission1; 
                float lerpemiss = R_MaskMap * _Layer1Alpha * Clamp_Alpha_Sample_BaseMap1;
                float4 temp1emiss = lerp(baseEmiss, emiss1, lerpemiss);
                float4 temp2emiss = lerp(baseEmiss, baseEmiss + (emiss1 * 4.599 * clamp(_Layer1Alpha, 1.0, 2.0)), lerpemiss);
                float4 blend_emiss1 = (( 1.0 == (float)(int)_Layer1Toggle ) ? (( 1.0 == (float)_Layer1BlendModel ) ? temp1emiss :  temp2emiss ) :  baseEmiss);

                float emissFactor2 = clamp(1.0 - (1.0 - sample_BaseMap2.a) * 2.1, 0.0, 1.0);
                float4 emiss2 = sample_BaseMap2 * emissFactor2 * _EmissionClr2 * _Emission2;
                lerpemiss = G_MaskMap * _Layer2Alpha * Clamp_Alpha_Sample_BaseMap2;
                temp1emiss = lerp(blend_emiss1, emiss2, lerpemiss);
                temp2emiss = lerp(blend_emiss1, blend_emiss1 + (emiss2 * 4.599 * clamp(_Layer2Alpha, 1.0, 2.0)), lerpemiss);
                float4 blend_emiss2 = (( 1.0 == (float)(int)_Layer2Toggle ) ? (( 1.0 == (float)_Layer2BlendModel ) ? temp1emiss :  temp2emiss ) :  blend_emiss1);

                float emissFactor3 = clamp(1.0 - (1.0 - sample_BaseMap3.a) * 2.1, 0.0, 1.0);
                float4 emiss3 = sample_BaseMap3 * emissFactor3 * _EmissionClr3 * _Emission3;
                lerpemiss = B_MaskMap * _Layer3Alpha * Clamp_Alpha_Sample_BaseMap3;
                temp1emiss = lerp(blend_emiss2, emiss3, lerpemiss);
                temp2emiss = lerp(blend_emiss2, blend_emiss2 + (emiss3 * 4.599 * clamp(_Layer3Alpha, 1.0, 2.0)), lerpemiss);
                float4 blend_emiss3 = (( 1.0 == (float)(int)_Layer3Toggle ) ? (( 1.0 == (float)_Layer3BlendModel ) ? temp1emiss :  temp2emiss ) :  blend_emiss2);

                float emissFactor4 = clamp(1.0 - (1.0 - sample_BaseMap4.a) * 2.1, 0.0, 1.0);
                float4 emiss4 = sample_BaseMap4 * emissFactor4 * _EmissionClr4 * _Emission4;
                lerpemiss = A_MaskMap * _Layer4Alpha * Clamp_Alpha_Sample_BaseMap4;
                temp1emiss = lerp(blend_emiss3, emiss4, lerpemiss);
                temp2emiss = lerp(blend_emiss3, blend_emiss3 + (emiss4 * 4.599 * clamp(_Layer4Alpha, 1.0, 2.0)), lerpemiss);
                float4 blend_emiss4 = (( 1.0 == (float)(int)_Layer4Toggle ) ? (( 1.0 == (float)_Layer4BlendModel ) ? temp1emiss :  temp2emiss ) :  blend_emiss3);
                float3 emiss = blend_emiss4.rgb; // 最终的自发光

                // 金属度
                float baseMetallic = sample_NormalMap.b * _MetallicIntensity;
                float baseMetallic1 = sample_NormalMap1.b * _MetallicIntensity1;
                float lerpMetallic = R_MaskMap * _Layer1Alpha * Clamp_Alpha_Sample_BaseMap1;
                float temp1Metallic = lerp(baseMetallic, baseMetallic1, lerpMetallic);
                float temp2Metallic = lerp(baseMetallic,  (baseMetallic + baseMetallic1) * 0.5, lerpMetallic);
                float blend_metallic1 = (( 1.0 == (float)(int)_Layer1Toggle ) ? (( 1.0 == (float)_Layer1BlendModel ) ? temp1Metallic :  temp2Metallic ) :  baseMetallic );

                float baseMetallic2 = sample_NormalMap2.b * _MetallicIntensity2;
                lerpMetallic = G_MaskMap * _Layer2Alpha * Clamp_Alpha_Sample_BaseMap2;
                temp1Metallic = lerp(blend_metallic1, baseMetallic2, lerpMetallic);
                temp2Metallic = lerp(blend_metallic1, (blend_metallic1 + baseMetallic2) * 0.5, lerpMetallic);
                float blend_metallic2 = (( 1.0 == (float)(int)_Layer2Toggle ) ? (( 1.0 == (float)_Layer2BlendModel ) ? temp1Metallic :  temp2Metallic ) :  blend_metallic1 );

                float baseMetallic3 = sample_NormalMap3.b * _MetallicIntensity3;
                lerpMetallic = B_MaskMap * _Layer3Alpha * Clamp_Alpha_Sample_BaseMap3;
                temp1Metallic = lerp(blend_metallic2, baseMetallic3, lerpMetallic);
                temp2Metallic = lerp(blend_metallic2, (blend_metallic2 + baseMetallic3) * 0.5, lerpMetallic);
                float blend_metallic3 = (( 1.0 == (float)(int)_Layer3Toggle ) ? (( 1.0 == (float)_Layer3BlendModel ) ? temp1Metallic :  temp2Metallic ) :  blend_metallic2 );

                float baseMetallic4 = sample_NormalMap4.b * _MetallicIntensity4;
                lerpMetallic = A_MaskMap * _Layer4Alpha * Clamp_Alpha_Sample_BaseMap4;
                temp1Metallic = lerp(blend_metallic3, baseMetallic4, lerpMetallic);
                temp2Metallic = lerp(blend_metallic3, (blend_metallic3 + baseMetallic4) * 0.5, lerpMetallic);
                float blend_metallic4 = (( 1.0 == (float)(int)_Layer4Toggle ) ? (( 1.0 == (float)_Layer4BlendModel ) ? temp1Metallic :  temp2Metallic ) :  blend_metallic3 );
                float metallic = blend_metallic4; // 金属度

                // 平滑度
                float baseSmooth = sample_NormalMap.a * _SmoothnessIntensity;
                float baseSmooth1 = sample_NormalMap1.a * _SmoothnessIntensity1;
                float lerpSmooth = R_MaskMap * _Layer1Alpha * Clamp_Alpha_Sample_BaseMap1;
                float temp1Smooth = lerp(baseSmooth, baseSmooth1, lerpSmooth);
                float temp2Smooth = lerp(baseSmooth, (baseSmooth + baseSmooth1) * 0.5, lerpSmooth);
                float blend_smooth1 = (( 1.0 == (float)(int)_Layer1Toggle ) ? (( 1.0 == (float)_Layer1BlendModel ) ? temp1Smooth :  temp2Smooth ) :  baseSmooth);

                float baseSmooth2 = sample_NormalMap2.a * _SmoothnessIntensity2;
                lerpSmooth = G_MaskMap * _Layer2Alpha * _SmoothnessIntensity2;
                temp1Smooth = lerp(blend_smooth1, baseSmooth2, lerpSmooth);
                temp2Smooth = lerp(blend_smooth1, (blend_smooth1 + baseSmooth2) * 0.5, lerpSmooth);
                float blend_smooth2 = (( 1.0 == (float)(int)_Layer2Toggle ) ? (( 1.0 == (float)_Layer2BlendModel ) ? temp1Smooth :  temp2Smooth ) :  blend_smooth1);

                float baseSmooth3 = sample_NormalMap3.a * _SmoothnessIntensity3;
                lerpSmooth = B_MaskMap * _Layer3Alpha * _SmoothnessIntensity3;
                temp1Smooth = lerp(blend_smooth2, baseSmooth3, lerpSmooth);
                temp2Smooth = lerp(blend_smooth2, (blend_smooth2 + baseSmooth3) * 0.5, lerpSmooth);
                float blend_smooth3 = (( 1.0 == (float)(int)_Layer3Toggle ) ? (( 1.0 == (float)_Layer3BlendModel ) ? temp1Smooth :  temp2Smooth ) :  blend_smooth2);

                float baseSmooth4 = sample_NormalMap4.a * _SmoothnessIntensity4;
                lerpSmooth = A_MaskMap * _Layer4Alpha * _SmoothnessIntensity4;
                temp1Smooth = lerp(blend_smooth3, baseSmooth4, lerpSmooth);
                temp2Smooth = lerp(blend_smooth3, (blend_smooth3 + baseSmooth4) * 0.5, lerpSmooth);
                float blend_smooth4 = (( 1.0 == (float)(int)_Layer4Toggle ) ? (( 1.0 == (float)_Layer4BlendModel ) ? temp1Smooth :  temp2Smooth ) :  blend_smooth3);
                float smooth = blend_smooth4; // 平滑度

                // AO
                //float occ = lerp( 1.0 , ( 1.0 - (( 3.0 == (float)_AOChannelSelect ) ? A_MaskMap :  (( 2.0 == (float)_AOChannelSelect ) ? B_MaskMap :  (( 1.0 == (float)_AOChannelSelect ) ? G_MaskMap :  (( 0.0 == (float)_AOChannelSelect ) ? R_MaskMap :  R_MaskMap ) ) ) ) ) , _AOIntensity);
			    //float occlusion = ( _AOToggle ) ? occ : 1.0;

                // 创建表面数据结构
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.BaseColor = baseColor;//(IsGammaSpace() ? baseColor : SRGBToLinear(baseColor)).rgb; // 基础纹理色
                surface.Emission = emiss;//IsGammaSpace() ? emiss : SRGBToLinear(emiss); // 自发光
                surface.Smoothness = smooth; // 平滑度
                surface.Metallic = metallic; // 金属度
                surface.NormalTS = normalTS; // 法线（切线空间）// IN.TangentSpaceNormal;
                surface.Occlusion = 1; // 遮挡
                surface.Alpha = 1; // 透明度
                surface.BentNormal = IN.TangentSpaceNormal; // 副法线
                {
                    surface.VTPackedFeedback = float4(1.0f,1.0f,1.0f,1.0f);
                }
                return surface;
            }
            // ////
            // END
            // ///////////////////////////////////////////////////////////////////

            
            // 构建 Surface 和 Builtin 数据结构
            #include "../HLSL/Graphi-LitSurfaceAndBuiltin-Forward.hlsl"
        
            // 主引用（包含顶点、片元处理程序、光照处理程序等核心包）
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForward.hlsl"
        	#ifdef HAVE_VFX_MODIFICATION
        	    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/VisualEffectVertex.hlsl"
        	#endif

            // 调用顶点、片元渲染程序
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
   
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "Rendering.HighDefinition.LitShaderGraphGUI" "UnityEngine.Rendering.HighDefinition.HDRenderPipelineAsset"
    Fallback "Hidden/Graphi/FallbackErr"
}