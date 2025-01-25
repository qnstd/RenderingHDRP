#ifndef LW_PROPERTIES
#define LW_PROPERTIES

// SRP 数据缓冲
CBUFFER_START(UnityPerMaterial)
    // PBR属性
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
    // 曲面细分属性
    float _TessFactor;
    float _TessMinDist, _TessMaxDist;
    // 毛发
    float _FaceViewThreshold;
    float _Density;
    float _RandomDirection;
    float _Length;
    float _NearSurface;
    float _WindPhase, _SwingPow;
    float3 _BaseOffset, _WindAxisWeight, _WindAxisSpeed;
    float _FaceNormalFactor;
    float _CutAlpha;
    float _FurNormalForce;
    float _Occ;
    float _DisplayOriginMesh;
CBUFFER_END


// 纹理及对应的采样器
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

TEXTURE2D(_FurTex);
SAMPLER(sampler_FurTex);
TEXTURE2D(_FurNormalTex);
SAMPLER(sampler_FurNormalTex);

#endif //着色属性 | 作者：强辰