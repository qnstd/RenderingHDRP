#ifndef FURPROPERTIES
#define FURPROPERTIES

// SRP 属性
CBUFFER_START(UnityPerMaterial)
    float _Metalness;
    float _Smoothness;
    float4 _Color;
    float4 _AlbedoTex_TexelSize;
    float4 _NormalTex_TexelSize;
    float _NormalStrength;
    float4 _MaskTex_TexelSize;
    float2 _MetalRemapping;
    float2 _SmoothRemapping;
    float2 _AORemapping;
    float _UseRemapping;
    float4 _CoatMask_TexelSize;
    float _Coat;
    float4 _EmissionTex_TexelSize;
    float4 _EmissionTex_ST;
    float4 _EmissionClr;
    float _ExposureWeight;
    float _MultiplyAlbedo;
    float4 _DetailTex_TexelSize;
    float _LockAlbedoTillingAndOffset;
    float _DetailAlbedoScal;
    float _DetailNormalScal;
    float _DetailSmoothnessScal;
    float4 _TillingAndOffset;
    float4 _DetailTillingAndOffset;
    float _Alp;
    float4 _EmissionColor;
    float _UseShadowThreshold;
    float4 _DoubleSidedConstants;
    float _BlendMode;
    float _EnableBlendModePreserveSpecularLighting;
    float _RayTracing;
    float _RefractionModel;
    // fur 参数
    float4 _FurMap_ST;
    float4 _FurNormalMap_ST;
    int _Length;
    float _Step;
    float _Cutoffs;
    float _Occlusion;
    float _Density;
    float4 _BaseOffset;
    float4 _WindAxisWeight;
    float4 _WindOffset;
    float _WindForce;
    float _WindDisturbance;
    float _FurNormalForce;
CBUFFER_END
        
        
// 纹理
TEXTURE2D(_AlbedoTex);
SAMPLER(sampler_AlbedoTex);
TEXTURE2D(_NormalTex);
SAMPLER(sampler_NormalTex);
TEXTURE2D(_MaskTex);
SAMPLER(sampler_MaskTex);
TEXTURE2D(_CoatMask);
SAMPLER(sampler_CoatMask);
TEXTURE2D(_EmissionTex);
SAMPLER(sampler_EmissionTex);
TEXTURE2D(_DetailTex);
SAMPLER(sampler_DetailTex);
TEXTURE2D(_FurMap); 
SAMPLER(sampler_FurMap);
TEXTURE2D(_FurNormalMap);
SAMPLER(sampler_FurNormalMap);

// ScenePickingPass 使用（着色器暂不支持此着色Pass）
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif
        
// SceneSelectionPass 使用（着色器暂不支持此着色Pass）
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif


#endif //绒毛着色属性、变量定义（由 Graphi 着色库工具生成）| 作者：强辰