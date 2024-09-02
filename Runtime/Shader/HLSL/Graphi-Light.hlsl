#ifndef GRAPHI_LIGHT
#define GRAPHI_LIGHT

//#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Sky/PhysicallyBasedSky/ShaderVariablesPhysicallyBasedSky.cs.hlsl"
//#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
//#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariablesGlobal.cs.hlsl"

// 主光信息
void MainLightInfo_float(out float3 forward, out float3 color, out float distanceFromCamera)
{
#if defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT)
    uint lightIndex = _DirectionalShadowIndex;
    if (_DirectionalShadowIndex < 0)
    {
        if (_DirectionalLightCount == 0)
        {
            forward = 0;
            color = 0;
            distanceFromCamera = -1;

            return;
        }
        lightIndex = 0;
    }

    // 获取相应的数据
    DirectionalLightData light = _DirectionalLightDatas[lightIndex];
    forward = light.forward;
    color = light.color;
    distanceFromCamera = light.distanceFromCamera;

#else
    forward = 0;
    color = 0;
    distanceFromCamera = -1;
#endif
}


//////////////////////////////////////////////////////////
// 最大最小粗糙度。 计算公式来源于物理网站的目测专栏。
// shapeRadiusVal : 光源的半径。平行光的情况下，此值为0.


// 光源 影响表面的最大粗糙度
float LightMaxSmoothness(float shapeRadiusVal)
{
    float v1 = 1.0f * (shapeRadiusVal + 0.1f);
    float value = 1.1725f / (1.01f + pow(v1,2)) - 0.15f;
    return clamp(value, 0, 1);
}


// 光源 影响表面的最小粗糙度
float LightMinSmoothness(float shapeRadiusVal)
{
    float maxSmoothness = LightMaxSmoothness(shapeRadiusVal);
    return (1.0f - maxSmoothness) * (1.0f - maxSmoothness);
}


// END
//////////////////////////////////////////////////////////



//#define FLT_EPS0  5.960464478e-8

//real OpticalDepthHeightFog0(real baseExtinction, real baseHeight, real2 heightExponents, real cosZenith, real startHeight)
//{
//    real H          = heightExponents.y;
//    real rcpH       = heightExponents.x;
//    real Z          = cosZenith;
//    real absZ       = max(abs(cosZenith), FLT_EPS0);
//    real rcpAbsZ    = rcp(absZ);

//    real minHeight  = (Z >= 0) ? startHeight : -rcp(FLT_EPS0);
//    real h          = max(minHeight - baseHeight, 0);

//    real homFogDist = max((baseHeight - minHeight) * rcpAbsZ, 0);
//    real expFogMult = exp(-h * rcpH) * (rcpAbsZ * H);

//    return baseExtinction * (homFogDist + expFogMult);
//}

//real TransmittanceFromOpticalDepth0(real opticalDepth)
//{
//    return exp(-opticalDepth);
//}

//real3 TransmittanceFromOpticalDepth0(real3 opticalDepth)
//{
//    return exp(-opticalDepth);
//}

//float ComputeCosineOfHorizonAngle0(float r)
//{
//    float R      = _PlanetaryRadius;
//    float sinHor = R * rcp(r);
//    return -sqrt(saturate(1 - sinHor * sinHor));
//}

//float ChapmanUpperApprox0(float z, float cosTheta)
//{
//    float c = cosTheta;
//    float n = 0.761643 * ((1 + 2 * z) - (c * c * z));
//    float d = c * z + sqrt(z * (1.47721 + 0.273828 * (c * c * z)));

//    return 0.5 * c + (n * rcp(d));
//}

//float ChapmanHorizontal0(float z)
//{
//    float r = rsqrt(z);
//    float s = z * r; // sqrt(z)
//    return 0.626657 * (r + 2 * s);
//}

//float3 ComputeAtmosphericOpticalDepth0(float r, float cosTheta, bool aboveHorizon)
//{
//    float2 n = float2(_AirDensityFalloff, _AerosolDensityFalloff);
//    float2 H = float2(_AirScaleHeight,    _AerosolScaleHeight);
//    float  R = _PlanetaryRadius;

//    float2 z = n * r;
//    float2 Z = n * R;

//    float sinTheta = sqrt(saturate(1 - cosTheta * cosTheta));

//    float2 ch;
//    ch.x = ChapmanUpperApprox0(z.x, abs(cosTheta)) * exp(Z.x - z.x); 
//    ch.y = ChapmanUpperApprox0(z.y, abs(cosTheta)) * exp(Z.y - z.y); 

//    if (!aboveHorizon) 
//    {
//        float sinGamma = (r / R) * sinTheta;
//        float cosGamma = sqrt(saturate(1 - sinGamma * sinGamma));

//        float2 ch_2;
//        ch_2.x = ChapmanUpperApprox0(Z.x, cosGamma); 
//        ch_2.y = ChapmanUpperApprox0(Z.y, cosGamma); 

//        ch = ch_2 - ch;
//    }
//    else if (cosTheta < 0) 
//    {
//        float2 z_0  = z * sinTheta;
//        float2 b    = exp(Z - z_0); 
//        float2 a;
//        a.x         = 2 * ChapmanHorizontal0(z_0.x);
//        a.y         = 2 * ChapmanHorizontal0(z_0.y);
//        float2 ch_2 = a * b;

//        ch = ch_2 - ch;
//    }

//    float2 optDepth = ch * H;

//    return optDepth.x * _AirSeaLevelExtinction.xyz + optDepth.y * _AerosolSeaLevelExtinction;
//}



//// 预估平行光源的颜色
//float4 EvaluationDirectionalLight(float3 forward, float3 c, float distanceFromCamera, float3 posRWS)
//{
//    float4 color = float4(c, 1.0);
//    float3 L = -forward;
    
//#ifndef LIGHT_EVALUATION_NO_HEIGHT_FOG
//    // 高度雾衰减
//    {
//        // 统一高度衰减
//        float  cosZenithAngle = max(L.y, 0.001f);
//        float  fragmentHeight = posRWS.y;
//        float3 oDepth = OpticalDepthHeightFog(_HeightFogBaseExtinction, _HeightFogBaseHeight, _HeightFogExponents, cosZenithAngle, fragmentHeight);
//        // 不能对天空和雾同时处理，否则天空会饱和
//        float3 transm = TransmittanceFromOpticalDepth0(oDepth);
//        color.rgb *= transm;
//    }
//#endif
    
//    bool interactsWithSky = asint(distanceFromCamera) >= 0;
//    if (interactsWithSky)
//    {
//        float3 X = GetAbsolutePositionWS(posRWS);
//        float3 C = _PlanetCenterPosition.xyz;

//        float r        = distance(X, C);
//        float cosHoriz = ComputeCosineOfHorizonAngle0(r);
//        float cosTheta = dot(X - C, L) * rcp(r); 

//        if (cosTheta >= cosHoriz)
//        {
//            float3 oDepth = ComputeAtmosphericOpticalDepth0(r, cosTheta, true);
//            float3 transm  = TransmittanceFromOpticalDepth0(oDepth);
//            float3 opacity = 1 - transm;
//            color.rgb *= 1 - (Desaturate(opacity, _AlphaSaturation) * _AlphaMultiplier);
//        }
//        else
//        {
//           color = 0;
//        }
//    }

//    // TODO: cookie
//    // end

//    color.rgb *= color.a;
//    return color;
//}






#endif //光（由 Graphi 着色库工具生成）| 作者：强辰