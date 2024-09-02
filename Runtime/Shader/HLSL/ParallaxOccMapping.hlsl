#ifndef PARALLAXOCCMAPPING
#define PARALLAXOCCMAPPING


// 采样高度图
float SampleHigh(UnityTexture2D tex, float2 uv, float lodlevel)
{
	return SAMPLE_TEXTURE2D_LOD(tex, tex.samplerstate, tex.GetTransformedUV(uv), lodlevel).r;
}



// 视差遮蔽映射 计算
void PallaxOccMap_float
( 
// 输入
float2 UV,					// 当前顶点的 UV 坐标
float3 ViewDirTangent,		// 顶点到摄像机的向量（切线空间）
UnityTexture2D HighMap,		// 高度纹理
float Amplitude,			// 偏移强度 （ 范围要求 [0, 1] ）
float RayTracingStep,		// 步进测试最大层数
float2 DynamicStepFactor,	// 动态步进倍数因子（参与每一次步进距离的计算，具体说明在函数体内被应用的地方。建议范围 [0.1, 2]）
bool DivideZ,				// UV投影偏移情况下是否除以Z轴
float LodLevel,				// 采样高度图的细节级别LOD（ 范围要求 [0, 7] ）
float3 PosVS,				// 顶点在视空间的位置
float2 FadeoutArea,			// 边界（x：开始淡出的距离，y：完全淡出、消失的距离。若这两个值相反，那么越近的情况下效果越小。）

// 输出
out float2 UVOffset		// 最终的UV偏移量
/*out float DepthOffset*/
)
{
	// 偏移强度（加入视距判断，过远情况下，将设定的强度设置为0。如果偏移强度为0的情况下，直接返回，无需制作偏移）
	float force = Amplitude;
	force *= 1 - smoothstep(FadeoutArea.x, FadeoutArea.y, length(PosVS));
	if(force == 0)
	{
		UVOffset = float2(0,0);
		return;
	}

	float2 offs = float2(0,0); // UV总偏移量
	float Aml = 0.999; // 高度（由于最大高度为1时，会造成部分像素形成破面情况。因此，将高度的最大值设置为无限逼近1的一个浮点值）
	float StepHigh = Aml; // 剩余步进高度
	float Step = Aml / RayTracingStep; // 单位步进高度
	float2 ViewOffset = (DivideZ) ? (ViewDirTangent.xy / ViewDirTangent.z) : ViewDirTangent.xy; // Z影响
	float2 Delta =  force * ViewOffset * Step; // 单次步进测试的UV偏移量
	float H = SampleHigh(HighMap, UV, LodLevel); // 当前UV对应的高度信息
	float dynamicStepFactor; // 动态步进倍数因子

	// 用于后期进行遮蔽插值运算的变量
	float2 OutUVOffs, InnerUVOffs;
	float LastH, LastStepHigh;

	// 循环步进测试（当采样的高度信息大于等于步进剩余高度，则说明完毕）
	//UNITY_LOOP //不进行循环展开检查
	for(int i=0; i < RayTracingStep && StepHigh > H; i++)
	{
		// 动态步进优化
		//		以当前步进高度及对应高度图中的高度做差值来作为预估或假设步进距离的系数。差值越小，预估或假设认为快与高度图的任意边缘相交，反之则认为还离得很远。
		//		这是一种预估假设行为，并不能完全证明差值大小能决定相交情况，只是用来做步进优化。在固定步进模式下，总会有资源浪费（每一步进的高度差都很大）的情况，
		//		此时需要尽可能的减少步进循环次数来加快测试，同时增强执行性能。对于准确性来说，目前没有方式能完全查找到真正的相交点，后续会对步进结果进行最大化的
		//      准确性优化。
		dynamicStepFactor = max(DynamicStepFactor.x, DynamicStepFactor.y * (StepHigh - H)); 
		
		OutUVOffs = offs;
		offs -= Delta * dynamicStepFactor;

		LastStepHigh = StepHigh;
		StepHigh -= Step * dynamicStepFactor;

		LastH = H;
		H = SampleHigh(HighMap, UV + offs, LodLevel); // 重新采样
	}

	if(StepHigh > H)
	{// 当光线步进检测结束时，由于最大步数较少原因，可能存在射线步进点未进入到高度图的内部(未和高度图的任意边缘相交)。这里直接返回最后一个步进点的UV偏移量.
		UVOffset = offs;
		return;
	}
	

	// 步进进入虚拟高度图内，进行插值优化
	// 用于对射线步进到虚拟高度图内部的第一个点与外部最近一个点之间的优化，更精确的查找接近真实的与高度图相交的点，同时获取对应的采样UV偏移。
	InnerUVOffs = offs;
	float curHighSplus = abs(H - StepHigh);
	float LastHighSplus = abs(LastH - LastStepHigh);
	float factor = curHighSplus / (curHighSplus + LastHighSplus);
	UVOffset = OutUVOffs * factor + InnerUVOffs * (1-factor);
}



#endif //视差遮蔽映射（由 Graphi 着色库工具生成）| 作者：强辰