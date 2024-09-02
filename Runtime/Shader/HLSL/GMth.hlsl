#ifndef GMTH
#define GMTH

// PI
#define pi 3.14159274F

// 角度转弧度
#define deg2rad pi / 180
// 弧度转角度
#define rad2deg 57.29578F



// 取参数值的符号
// 返回值：正数，1、负数，-1
float Sign(float f)
{
	//return (f >= 0) ? 1 : (-1);
	return ( step(0, f) == 0 ) ? (-1) : 1;
}


// 拷贝符号
// 返回值：取参数1的值，取参数2的符号
float CopySign(float x, float y)
{
    return abs(x) * Sign(y);
}


// 参数平方根分之一
float OnepartSqrt(float val)
{
	return 1.0 / sqrt(val);
}



// 重复运动
// 根据参数t（时间），在 0-len 范围内重复运动
float Repeat(float t, float len)
{
	return clamp(t - floor(t / len) * len, 0, len);
}


// PingPong 运动
// 根据参数t（时间），在 0-len 范围内往返运动
float PingPong(float t, float len)
{
	t = Repeat(t, len * 2);
    return len - abs(t - len);
}


#endif // Math 函数库（由 Graphi 着色库工具生成）| 作者：强辰