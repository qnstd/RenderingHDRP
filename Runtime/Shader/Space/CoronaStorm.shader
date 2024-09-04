/*
	星体周围的风暴、日冕
	例如：太阳

	渲染管线：
		High-Definition RenderPipeline

	作者：
		强辰
*/
Shader "Graphi/Space/CoronaStorm"
{
    Properties
    {
		[Foldout]_B("Base", Range(0,1)) = 1
		[To(_B)][HDR]_TintColor("Color", Color) = (1,1,1,1)
		[To(_B)][SingleLine]_HybridMap("Mix Map", 2D) = "white" {}
       
		[Foldout]_S("Storm", Range(0,1)) = 1
		[To(_S)]_StormTileX("X tile", Float) = 0
		[To(_S)]_StormTileY("Y tile", Float) = 0
		[To(_S)]_StormPower("Force", Float) = 0
		[To(_S)]_StormPow("Pow", Float) = 0
		[To(_S)]_FluidTile("Tile", Float) = 0
		[To(_S)]_FluidInfluence("Force", Float) = 0
		[To(_S)]_FluidSped("Speed", float) = 0

		[Foldout]_C("Corona", Range(0,1)) = 1
		[To(_C)]_CoronaTileX("X tile", Float) = 0
		[To(_C)]_CoronaTileY("Y tile", Float) = 0
		[To(_C)]_CoronaSpeed("Speed", Float) = 0
		[To(_C)]_CoronaAmp("Force", Float) = 0
		[To(_C)]_CoronaExp("Pow", Float) = 0

		[Foldout]_D("LightRing", Range(0,1)) = 1
		[To(_D)]_DiaphragmBoost("Boost", Float) = 0
		[To(_D)]_DiaphragmPow("Force", Float) = 0

		[Foldout]_O("Other", Range(0,1)) = 1
		[To(_O)]_ViewPow("Force", Float) = 0
		[To(_O)]_ViewBoost("Boost", Float) = 0
		[To(_O)]_SoftFade("Fade", Range(0.001,1)) = 0.001

		// 隐藏属性
		[HideInInspector] _AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0
        [HideInInspector]_BlendMode("_BlendMode", Range(0.0, 1.0)) = 0.5
    }


    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    // #pragma enable_d3d11_debug_symbols
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON

    ENDHLSL


    SubShader
    {
        Tags
		{ 
			"RenderPipeline" = "HDRenderPipeline" 
			"Queue" = "Transparent" 
			"IgnoreProjector"="True"  
		}

        Pass
        {
            Name "Graphi CoronaStorm"
            Tags { "LightMode" = "Forward" }

            Blend One One
            ZWrite Off
            ZTest LEqual
            Cull Off

            HLSLPROGRAM

            #define _ALPHATEST_ON
            #define _SURFACE_TYPE_TRANSPARENT
            //#define _ENABLE_FOG_ON_TRANSPARENT
            
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_POSITION_WS

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            // 纹理
            TEXTURE2D(_HybridMap); 
            SAMPLER(sampler_HybridMap);

           // SRP 属性
CBUFFER_START(UnityPerMaterial)
float4 _TintColor ;
float4 _HybridMap_ST;
float _ViewPow, _ViewBoost ;
float _DiaphragmBoost, _DiaphragmPow ;
float _StormTileY, _StormTileX , _FluidSped , _StormPow, _StormPower, _FluidTile, _FluidInfluence;
float _CoronaTileX, _CoronaTileY, _CoronaSpeed, _CoronaAmp, _CoronaExp ;
float _SoftFade ;

float _AlphaCutoff;
float _BlendMode;
CBUFFER_END

			
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderersV2.hlsl"
			#include "../HLSL/Graphi_Transformation.hlsl"


            // 顶点修改
            #define HAVE_MESH_MODIFICATION
            AttributesMesh ApplyMeshModification(AttributesMesh input, float3 timeParameters)
            {
                return input;
            }


			// 计算可视范围
			float Cal_VisualScope(float3 viewDirection, float3 normalWS)
			{
				float VdotN = dot( normalize( viewDirection ) , normalWS );
				return saturate(  pow( abs( VdotN ) , _ViewPow ) * _ViewBoost );
			}

			// 交叉处弱化
			float Cal_SoftFade(float4 posSS)
			{
				float SceneZ = LinearEyeDepth(LoadCameraDepth(posSS.xy), _ZBufferParams);
				float ObjZ = posSS.w;
				return saturate((SceneZ - ObjZ) * _SoftFade);
			}


            // 表面渲染程序
            void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 viewDirection, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
				// 临时常量
				float pi = 3.1415926;
				float pi2 = pi * 2.0;
				float2 temp_cast_05 = (0.5).xx;
				float2 temp_cast_10 = (1.0).xx;
				float2 temp_cast_20 = (2.0).xx;
				float2 temp_vector_01 = float2(0, -1); // y轴变化量

				// 后续需要参与计算的变量
                float2 uv0 = fragInputs.texCoord0.xy; //uv0
				float2 uv0_02 = uv0 * 2.0; // uv0 扩大2倍 （由0-1，变成0-2）
				float2 uv0_02_temp_cast_10 = uv0_02 - temp_cast_10; // 将UV值扩大2倍，并减去中心（1,1）位置，得到 UV 方向向量
				float2 uv0_temp_case_05 = uv0 - temp_cast_05; // 原始uv与中心点的方向向量
				float2 uvDistPow = pow( uv0_02_temp_cast_10 , temp_cast_20 ) ; // 对 UV 方向向量进行 Pow 指数操作（就是对x，y分别进行2的幂操作，x^2, y^2）
				float uvDist = sqrt( uvDistPow.x + uvDistPow.y ); // 求出 UV 距中心位置的距离
				float2 uvDistPow05 = pow( uv0_temp_case_05, temp_cast_20 );  // 原始uv与中心点方向向量进行 Pow 指数操作
				float uvDist05 = sqrt( uvDistPow05.x + uvDistPow05.y ); // 求出原始uv居中心位置的距离
				float atan2_ = -atan2( uv0_02_temp_cast_10.y , uv0_02_temp_cast_10.x ); // 求出向量夹角
				float atan2Percent = (atan2_ >= 0.0) ? atan2_ / pi2 : (atan2_ + pi2) / pi2 ; // 如果夹角弧度值小于0，则加上pi2（360）转正后除以pi2（360），求出弧度占比值；
				
				// 光圈形状遮罩
				float Diaphragm_Inner = saturate(pow( 4 * uvDist05, 3 ))* 3.5 ;
				float Diaphragm_Out = saturate( 1.0 - pow( 2.25 * uvDist05 , 0.01 ));
				float Diaphragm = saturate( pow( Diaphragm_Inner * Diaphragm_Out  * _DiaphragmBoost , _DiaphragmPow ) );

				// 日冕计算
				float2 coronaSampleUVBase = float2( atan2Percent * _CoronaTileX , uvDist * _CoronaTileY );
				float2 coronaSampleUV = coronaSampleUVBase + ( _Time.x * _CoronaSpeed ) * temp_vector_01;
				float coronaSampleResult = SAMPLE_TEXTURE2D( _HybridMap, sampler_HybridMap, coronaSampleUV ).g;
				float corona = pow( coronaSampleResult * _CoronaAmp, _CoronaExp );
				float Corona = Diaphragm + corona ;

				// 风暴、风暴遮罩计算
				float radialCircle = saturate( 1.0 - pow( 3.75 * sqrt( 0.65 * (uvDistPow05.x + uvDistPow05.y) ), 3 ) );
				float2 uv_rotate = UVRot2( 4.0 , uv0_02 ); // UV增加2倍的密度并旋转
				float StormNoiseMsk = pow( SAMPLE_TEXTURE2D( _HybridMap, sampler_HybridMap, uv_rotate ).r, 1.25 ) * 2.0 * radialCircle ; // 风暴噪声遮罩

				float2 StormSampleUV = float2( _StormTileX * 0.5 * atan2Percent , uvDist * 0.5 * _StormTileY );
				float StormBase = SAMPLE_TEXTURE2D( _HybridMap, sampler_HybridMap, StormSampleUV ).g;
				float2 FluidSampleUV = UVRot2( _Time.x * _FluidSped , uv0 * _FluidTile * 4.0 );
				float Fluid = SAMPLE_TEXTURE2D( _HybridMap, sampler_HybridMap, FluidSampleUV ).r * _FluidInfluence;
				float2 StormSampleUV2 = float2( _StormTileX * atan2Percent , uvDist * _StormTileY );
				float StormFluid = SAMPLE_TEXTURE2D( _HybridMap, sampler_HybridMap, StormSampleUV2 + Fluid ).r;
				float Storm = pow( StormBase * StormFluid , _StormPow ) * _StormPower;
				
				// 组合
				float4 result = 
								_TintColor * 
								( StormNoiseMsk * Storm  + Corona ) * Diaphragm * 5.0 *
								Cal_SoftFade(fragInputs.positionSS) *  
								Cal_VisualScope(viewDirection, fragInputs.tangentToWorld[2])
								;
				float3 color = result.rgb;
				float opacity = result.a;

				// AlphaTest 透明测试
#ifdef _ALPHATEST_ON
                DoAlphaTest(opacity, _AlphaCutoff);
#endif
                
                // 回传数据
                ZERO_BUILTIN_INITIALIZE(builtinData);
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                builtinData.opacity = opacity;
                builtinData.emissiveColor = float3(0, 0, 0);
                surfaceData.color = color;
            }

            // 执行
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForwardUnlit.hlsl"
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    FallBack "Hidden/Graphi/FallbackErr"
	CustomEditor "com.graphi.renderhdrp.editor.SunCoronaShaderGUI"
}