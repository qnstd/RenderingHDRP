#ifndef IRIDESCENCE
#define IRIDESCENCE


#include "Graphi-Light.hlsl"
#include "Graphi_Color.hlsl"


void GetBSDF0(real3 V, real3 L, real NdotL, real NdotV,
                  out real LdotV, out real NdotH, out real LdotH, out real invLenLV)
{
    LdotV = dot(L, V);
    invLenLV = rsqrt(max(2.0 * LdotV + 2.0, 5.960464478e-8));
    NdotH = saturate((NdotL + NdotV) * invLenLV);
    LdotH = saturate(invLenLV * LdotV + invLenLV);
}


real SmithJointGGX(real NdotH, real NdotL, real NdotV, real roughness, real partLambdaV)
{
    real a2 = Sq(roughness);
    real s = (NdotH * a2 - NdotH) * NdotH + 1.0;

    real lambdaV = NdotL * partLambdaV;
    real lambdaL = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

    real2 D = real2(a2, s * s);            
    real2 G = real2(1, lambdaV + lambdaL); 
   
    return 0.31830988618379067154 * 0.5 * (D.x * G.x) / max(D.y * G.y, 6.103515625e-5 ); // 1.175494351e-38    6.103515625e-5
}


real GetSmithJointGGXPartLambdaV0(real NdotV, real roughness)
{
    real a2 = Sq(roughness);
    return  sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
}


real3 F(real3 f0, real u)
{
    real x = 1.0 - u;
    real x2 = x * x;
    real x5 = x * x2 * x2;
    return f0 * (1.0 - x5) + (1.0 * x5);
}

real F0(real f0, real f90, real u)
{
    real x = 1.0 - u;
    real x2 = x * x;
    real x5 = x * x2 * x2;
    return (f90 - f0) * x5 + f0; 
}

static const half3x3 XYZ_2_REC709_MAT0 = 
{
     3.2409699419, -1.5373831776, -0.4986107603,
    -0.9692436363,  1.8759675015,  0.0415550574,
     0.0556300797, -0.2039769589,  1.0569715142
};
real3 EvalSensitivity0(real opd, real shift)
{
    real phase = 2.0 * PI * opd * 1e-6;
    real3 val = real3(5.4856e-13, 4.4201e-13, 5.2481e-13);
    real3 pos = real3(1.6810e+06, 1.7953e+06, 2.2084e+06);
    real3 var = real3(4.3278e+09, 9.3046e+09, 6.6121e+09);
    real3 xyz = val * sqrt(2.0 * PI * var) * cos(pos * phase + shift) * exp(-var * phase * phase);
    xyz.x += 9.7470e-14 * sqrt(2.0 * PI * 4.5282e+09) * cos(2.2399e+06 * phase + shift) * exp(-4.5282e+09 * phase * phase);
    xyz /= 1.0685e-7;

    real3 srgb = mul(XYZ_2_REC709_MAT0, xyz);
    return srgb;
}


TEMPLATE_2_REAL(IorToFresnel, transmittedIor, incidentIor, return Sq((transmittedIor - incidentIor) / (transmittedIor + incidentIor)) )
real IorToFresnel(real transmittedIor)
{// ior 折射率的值在 1.0 到 3.0 之间. 1.0 is 空气
    return IorToFresnel(transmittedIor, 1.0);
}


float ClampNdotV0(float ndotv)
{
    return max(ndotv, 0.0001);
}


float3 AirToClearCoat(float3 c)
{
    return saturate(-0.0256868 + c * (0.326846 + (0.978946 - 0.283835 * c) * c));
}


float RoughnessPow(float roughness)
{
    return roughness * roughness;
}

// 将清漆加入到粗糙度的计算中
float ClearCoatAddToRoughness(float coat, float roughness)
{
    float ieta = lerp(1.0, 1.0 / 1.5, coat);
    float coatRoughnessScale = Sq(ieta);
    float sigma = 2.0 / Sq(RoughnessPow(roughness)) - 2.0;
    sigma *= coatRoughnessScale;
    return sqrt( sqrt(2.0 / (sigma + 2.0)) );
}


// 将各向异性加入到粗糙度的计算中
void AnisotropyAddToRougnhess(real roughness, real anisotropy, out real roughnessT, out real roughnessB)
{
    // 基于物理的着色
    real r = RoughnessPow(roughness);
    roughnessT = r * (1 + anisotropy);
    roughnessB = r * (1 - anisotropy);
}

void OptRoughness(inout float roughness, inout float roughnessCoat)
{
    float minRoughness = LightMinSmoothness(0); // 光源影响的最小粗糙度. 0: 表示平行光的半径

    roughness = max(minRoughness, roughness);
    roughnessCoat = max(minRoughness, roughnessCoat);
}



/////////////////////////////////////////////////////////////////
// 自定义薄膜干涉

// zucconi6 提出的自定义可见光光谱
// 光谱范围：700 - 400 nm

static const float3 c1 = float3(3.54585104, 2.93225262, 2.41593945);
static const float3 x1 = float3(0.69549072, 0.49228336, 0.27699880);
static const float3 y1 = float3(0.02312639, 0.15225084, 0.52607955);
static const float3 c2 = float3(3.90307140, 3.21182957, 3.96587128);
static const float3 x2 = float3(0.11748627, 0.86755042, 0.66077860);
static const float3 y2 = float3(0.84897130, 0.88445281, 0.73949448);

float3 Bump3y (float3 x, float3 yoffset)
{
    float3 y = 1 - x * x;
    y = saturate(y-yoffset);
    return y;
}

float3 Spectral_zucconi6(float w)
{
	float x = saturate((w - 400.0) / 300.0);
    return  
            Bump3y(c1 * (x - x1), y1) +
            Bump3y(c2 * (x - x2), y2) 
            ;
}

void Iridescence_float
(
float iorIntensity, // 折射强度
float iorThickness,  // 折射厚度
float3 posRWS, // 相对摄像机空间的世界坐标
float3 normalWS, // 世界空间法线
float3 mainLightForward, // 主光方向
float smooth, // 平滑度
float coat, // 清漆
// out params
out float3 color
)
{
    /*
        公式： 
            ior * 2 * d * cosTheta = (n + 0.5) * w; 

                ior      : 折射率（每种介质的折射率范围是不一样的） 
                d        : 厚度（介质）
                cosTheta : N （法线） 点乘  V（视向量）
                n        : 由于光束中存在多种颜色光线，而每种光线的波长不一致，会导致光线分散。n就是散开值。
        
        参考：
            https://www.alanzucconi.com/2017/07/15/the-nature-of-light/
    */

    if(iorIntensity <= 0)
    {
        color = 0;
        return;
    }

    // 准备计算的数据
    float3 L = -mainLightForward;
    float3 V = GetWorldSpaceNormalizeViewDir(posRWS);
    float3 N = normalWS;

    float LdotV, NdotH, LdotH, invLenLV;
    float NdotL = dot(N, L);
    float NdotV = dot(N, V);
    GetBSDF0(V, L, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);
    float clampNdotV = ClampNdotV0(NdotV);

    float ior = lerp(1.0, 1.5, coat); // 折射率
    float cosTheta = (coat != 0) ? sqrt(1.0 + Sq(1.0 / ior) * (Sq(NdotV) - 1.0)) : clampNdotV; // 折射角度

    // 计算薄膜干涉
    color = 0;
    float val = (ior * 2 * iorThickness * (cosTheta));
    for(int n=0; n<=4; n++)
    {
        float w = val / (n + 0.5);
        color.rgb += Spectral_zucconi6(w);
    }
    color = saturate(color);
    color *= iorIntensity;

    // ggx (逆光情况下不可见)
    float roughness = 1 - smooth;
    float ggx = SmithJointGGX(
                                NdotH,  
                                abs(NdotL), 
                                clampNdotV,  
                                roughness,
                                GetSmithJointGGXPartLambdaV0(clampNdotV, roughness)
                            );
    color *= ggx;
    if(NdotL > 0)
    {
        color *= saturate(NdotL);
    }
}

// 结束
/////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////
// 基于 unity 内置的 PBR - F值 修改的薄膜干涉算法

void Iridescence2_float
(
float iorMask, // 折射强度
float iorThickness,  // 厚度
float3 posRWS, // 相对摄像机空间的世界坐标
float3 normalWS, // 世界空间法线
float3 lforward, // 主光方向
float3 lcolor, // 主光颜色
float metallic, // 金属度
float smooth,  // 平滑度
float coat, // 清漆
float3 baseColor, // 基础色
out float3 color)
{
    if(iorMask <= 0.0)
    {
        color = baseColor;
        return;
    }

    // 准备计算的数据
    float3 baseColorGray = Gray(baseColor);
    float3 fresnel0 = lerp((0.04).xxx, baseColorGray, metallic); // 菲涅尔
    
    float3 L = -lforward;
    float3 V = GetWorldSpaceNormalizeViewDir(posRWS);
    float3 N = normalWS;

    float LdotV, NdotH, LdotH, invLenLV;
    float NdotL = dot(N, L);
    float NdotV = dot(N, V);
    GetBSDF0(V, L, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);
    float clampNdotV = ClampNdotV0(NdotV);


    // 菲涅尔薄膜干涉计算
    float ior = lerp(1.0, 1.5, coat); // 折射率
    float costheta = (coat != 0) ? sqrt(1.0 + Sq(1.0 / ior) * (Sq(NdotV) - 1.0)) : clampNdotV; // 折射角度
    float3 fresnelIri;
    real Dinc = 3.0 * iorThickness;
    real eta_2 = lerp(2.0, 1.0, iorThickness);
    real sinTheta2Sq = Sq(ior / eta_2) * (1.0 - Sq(costheta));
    real cosTheta2Sq = (1.0 - sinTheta2Sq);
    if (cosTheta2Sq < 0.0)
        fresnelIri = real3(1.0, 1.0, 1.0);
    else
    {
        real cosTheta2 = sqrt(cosTheta2Sq);
        real R0 = IorToFresnel(eta_2, ior);
        real R12 = F(R0, costheta);
        real R21 = R12;
        real T121 = 1.0 - R12;
        real phi12 = 0.0;
        real phi21 = PI - phi12;

        real3 R23 = F(fresnel0, cosTheta2);
        real  phi23 = 0.0;

        real OPD = Dinc * cosTheta2;
        real phi = phi21 + phi23;

        real3 R123 = clamp(R12 * R23, 1e-5, 0.9999);
        real3 r123 = sqrt(R123);
        real3 Rs = Sq(T121) * R23 / (real3(1.0, 1.0, 1.0) - R123);

        real3 C0 = R12 + Rs;
        fresnelIri = C0;

        real3 Cm = Rs - T121;
        for (int m = 1; m <= 2; ++m)
        {
            Cm *= r123;
            real3 Sm = 2.0 * EvalSensitivity0(m * OPD, m * phi);
           fresnelIri += Cm * Sm;
        }
        fresnelIri = max(fresnelIri, float3(0.0, 0.0, 0.0));
    }


    // 预处理光数据中的fresnel影响
    float3 f = lerp(fresnel0, fresnelIri, iorMask);
    f *= iorMask;
    if(coat != 0)
    {// 开启清漆，对薄膜干涉颜色进行处理。使薄膜干涉颜色变得更深一些，对比度更高一些，表现更强烈一些。
        f = lerp(f, AirToClearCoat(f) , coat);
    }

    // BSDF
    float3 _F = F(f, LdotH);
    _F = lerp(_F, f, iorMask);

    // 粗糙度
    float roughness = 1 - smooth;
    float roughnessCoat = 0.01;
    roughness =  ClearCoatAddToRoughness(coat, roughness);
    OptRoughness(roughness, roughnessCoat);
    //real roughnessT, roughnessB;
    //AnisotropyAddToRougnhess(roughness, 0, roughnessT, roughnessB);
    //OptRoughness(roughnessT, roughnessCoat);
    //roughness = roughnessT;


    // GGX
    float ggx = SmithJointGGX(
                                NdotH,  
                                abs(NdotL), 
                                clampNdotV,  
                                roughness,
                                GetSmithJointGGXPartLambdaV0(clampNdotV, roughness)
                            );
    float3 term = _F * ggx;
    
    // 清漆对term的影响
    if(coat != 0)
    {
        float coatF = F0(0.04, 1.0, LdotH) * coat;
        term *= Sq(1.0 - coatF);

        float DV = SmithJointGGX(
                                    NdotH, 
                                    abs(NdotL), 
                                    clampNdotV, 
                                    roughnessCoat, 
                                    GetSmithJointGGXPartLambdaV0(clampNdotV, roughnessCoat)
                                );
        term += coatF * DV;
    }

    // 优化term
    if(NdotL > 0)
    {
        term *= saturate(NdotL);
    }

     
    // 计算最终颜色
    color = term * lcolor;
    color = Hue(float4(color,1.0), 0.8, 1.25, 1.05).rgb;
    color += baseColor;
}

// 结束
/////////////////////////////////////////////////////////////////

#endif //薄膜干涉（由 Graphi 着色库工具生成）| 作者：强辰