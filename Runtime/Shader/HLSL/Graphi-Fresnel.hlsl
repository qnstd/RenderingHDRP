#ifndef GRAPHI_FRESNEL
#define GRAPHI_FRESNEL


/*
	菲涅尔边缘光
	viewWS		: 世界空间下的观察向量
	nWS			: 世界空间法线
	c			: 颜色
	p			: 范围
	f			: 强度
*/
void Fresnel_float(float3 viewWS, float3 nWS, float4 c, float p, float f, out float4 Out)
{
	float VdotN = saturate(1 - dot(viewWS, nWS));
	float VdotN_pow = saturate(SafePositivePow_float(VdotN, p));
	float4 F = VdotN_pow * c * f;
	Out = F;
}



/*
	菲涅尔边缘光（带主光）
	nWS							: 世界空间法线
	viewWS						: 世界空间下的观察向量
	mainLightForward			: 主光方向
	mainLightColor				: 主光颜色
	mainLightColorAttenFlag		: 主光颜色衰减开关
	mainLightSensitivity		: 视线对主光颜色敏感度
	mainLightSensiPow			: 视线对主光颜色敏感度指数
	c							: 菲涅尔叠加颜色
	p							: 范围
	f							: 强度
*/
void FresnelLight_float
(
// input
float3 nWS,
float3 viewWS,
float3 mainLightForward,
float3 mainLightColor,
bool mainLightColorAttenFlag,
float mainLightSensitivity,
float mainLightSensiPow,
float3 exposure,
float4 c,
float p,
float f,
float offs,
// out
out float4 Out
)
{
	float NdotV = dot( nWS , viewWS );
	float Abs_NdotV = abs( NdotV );

    // 计算发光
	float GlowOffset = saturate( ( Abs_NdotV + ( offs / 10 ) ) * 1000 );
	float4 glow = GlowOffset * saturate( pow( 1.0 - saturate( NdotV ) , p ) * c * f );

    float3 lightColor = mainLightColor * exposure; 
	float3 L = normalize(mainLightForward); 
	float LdotN = dot( -L, nWS ); // 光源负方向与法线点积，用于计算当前顶点受光基础程度
	float LdotV = dot( L , viewWS ); // 光源方向与视角方向点积，用于计算视觉对光源的敏感度

    // 平行光相对视线衰减
    float attenFlag = step(1, mainLightColorAttenFlag);
    float atten =  attenFlag * (1-saturate(LdotV)) + (1-attenFlag);
	float sensitivity = saturate( pow( saturate( LdotN + ( max( LdotV , -0.22 ) * mainLightSensitivity ) ) , mainLightSensiPow ) );

	Out.rgb = ( glow * sensitivity * lightColor * atten ).rgb;
	Out.a = 1;
}

#endif //菲涅尔边缘光（由 Graphi 着色库工具生成）| 作者：强辰