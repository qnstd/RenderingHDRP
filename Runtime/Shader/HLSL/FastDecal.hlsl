#ifndef FASTDECAL
#define FASTDECAL


// 输入参数
	// posRWS				: 相对摄像机的世界空间位置
	// eyeDepth				: 场景深度（视空间下深度）
	// tex2D				: 纹理
	// color				: 纹理叠加色
	// brightnessVal		: 亮度
	// projDistance			: 投影距离
// 输出参数
	// rgb		: 对应片元的BaseColor值
	// alp		: alpha值
void CalculateFastDecal_float
(
// Input Params
	float3 posRWS, 
	float eyeDepth, 
	UnityTexture2D tex2D, 
	float4 color, 
	float brightnessVal,
	float projDistance,
// Out Params
	out float3 rgb, 
	out float alp
)
{
	// 计算摄像机到当前像素所对应的场景深度位置的方向向量（视空间下）
	float3 viewDirInWorldSpace = GetWorldSpaceNormalizeViewDir( posRWS );
	float3 viewDirInViewSpace = TransformWorldToViewDir( viewDirInWorldSpace );
	float d;
	//d = LinearEyeDepth( SHADERGRAPH_SAMPLE_SCENE_DEPTH( posNDC.xy ), _ZBufferParams ) ;// LinearEyeDepth( LoadCameraDepth( posNDC.xy ), _ZBufferParams );
	//d *= -1;
	d = eyeDepth * ( -1 );
	float scal = d / viewDirInViewSpace.z;
	viewDirInViewSpace *= scal;

	// 计算摄像机在视空间下的位置
	float3 camPosInView = TransformWorldToView( GetCameraRelativePositionWS( _WorldSpaceCameraPos.xyz ) );

	// 计算实际的位置
	float3 pos = camPosInView + viewDirInViewSpace;

	// 判断是否执行贴花投影
	rgb = float3(0,0,0);
	alp = 0;
	float distanceShow = 1 - step(projDistance, length(pos));
	if(projDistance < 0 || distanceShow == 1)
	{// projDistance < 0：代表始终进行投影

		// 将实际位置的转为对象空间位置，用于后续采样
		pos = TransformWorldToObject( TransformViewToWorld( pos ) );

		// 根据计算的位置重新计算采样UV
		float2 sampleUV = pos.xz + (0.5).xx;

		// alpha裁剪值（裁剪掉投影立方体之外的像素）
		float clipOut = ( 1 - step( 0.5, abs(pos.x) ) ) * ( 1 - step( 0.5, abs(pos.z) ) );

		// 采样
		float2 uv = float2(0, 0); 
		#if defined( _TEXWRAPMODE_REPEAT ) 
			uv = tex2D.GetTransformedUV( sampleUV );

		#elif defined( _TEXWRAPMODE_CLAMP )
			uv = frac( tex2D.GetTransformedUV( sampleUV ) );
	
		#endif

		float4 c = SAMPLE_TEXTURE2D(tex2D, tex2D.samplerstate, uv) * color;
		c *= brightnessVal;
		rgb = c.rgb;
		alp = c.a * clipOut;
	}
}



#endif //轻量级贴花着色方案（快速处理）（由 Graphi 着色库工具生成）| 作者：强辰