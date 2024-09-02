#ifndef GRAPHI_RAINDROP
#define GRAPHI_RAINDROP


// 伪随机函数
float R(float2 p)
{
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x + p.y);
}



// 雨滴渲染层
float3 RenderLayer
(
// 输入参数
    float2 _UV,
    float _Tile, 
    float2 _Aspect,
    float _TrailDensity,
    float _Speed,
    float _RainDropXMove
)
{
    float2 center = (0.5).xx;
    float t = _Time.y; // fmod(_Time.y, 5); // fmod用于重置随机因子，表现不是特别好，暂时取消
    float speed = t * _Speed;

    // 当前UV
    float2 uv = _UV * _Tile * _Aspect.xy;
    uv.y += speed;
    float2 _uv = frac(uv) - center; // UV范围由 [0,1] 调整到 [-0.5, 0.5] 

    // 伪随机
    float r = R(floor(uv)); // [0-1]
    t += r * 6.2831; // 6.2831 = 2pi，为后sin函数做准备

    // 雨滴 
    float xoffsetForce = _UV.y * _RainDropXMove;
    float dropXMove = (r - 0.5) * 0.9; // 范围[-0.45, 0.45] // 限制在 [-0.5, 0.5] 范围的边距内
    dropXMove += (0.45 - abs(dropXMove)) * sin(3 * xoffsetForce) * pow(sin(xoffsetForce), 6) * 0.45; // x轴运动轨迹方程
    float dropYMove = -sin(t + sin(t + sin(t) * 0.5)) * 0.45; // y轴运动轨迹方程
    float2 dropPos = (_uv - float2(dropXMove, dropYMove)) / _Aspect.xy; // 除以_Aspect.xy的作用是将雨滴变成圆形。
    float drop = smoothstep(0.05, 0.03, length(dropPos)); // 平滑径向绘制雨滴
                
    // 雨滴拖尾
    float2 trailPos = (_uv - float2(dropXMove, speed)) / _Aspect.xy;
    trailPos.y = (frac(trailPos.y * _TrailDensity) - center) / _TrailDensity;
    float trail = smoothstep(0.03, 0.01, length(trailPos));

    // 雨滴水痕
    float waterStain = smoothstep(0.5, dropYMove, _uv.y); //渐变
    waterStain *= smoothstep(-0.05, 0.05, dropPos.y);// 位于雨滴下方的水痕进行删除

    // 将水痕的效果应用到雨滴拖尾上
    trail *= waterStain;

    // 优化水痕在x轴的范围
    waterStain *= smoothstep(0.05, 0.03, abs(dropPos.x)); // 范围 [0-1]

    float2 uvOffset = drop * dropPos + trail * trailPos ; // dropPos和trailPos表示对正常uv的扭曲偏移量，drop和trail是对偏移量的强度

    // 返回数据
    return float3(uvOffset.xy, waterStain);
}



// 计算雨滴的相关信息
// 对应自定义 ShaderGraph 中的 RainDropInfo CustomFunction 
void RainDropInfo_float // float 是 unity 规定与 Precision 匹配的后缀
(
// 输入参数
    float2 _OrignUV,
    float _Tile, 
    float2 _Aspect,
    float _TrailDensity,
    float _Speed,
    float _RainDropXMove,
    float2 _Layer1,
    float2 _Layer2,
// 输出参数
    out float3 _RainDropInfo
)
{
    _RainDropInfo = RenderLayer(_OrignUV, _Tile, _Aspect, _TrailDensity, _Speed, _RainDropXMove);
    if(_Layer1.x != 0 && _Layer1.y != 0)
        _RainDropInfo += RenderLayer(_OrignUV * _Layer1.x + _Layer1.y, _Tile, _Aspect, _TrailDensity, _Speed, _RainDropXMove);
    if(_Layer2.x != 0 && _Layer2.y != 0)
        _RainDropInfo += RenderLayer(_OrignUV * _Layer2.x + _Layer2.y, _Tile, _Aspect, _TrailDensity, _Speed, _RainDropXMove);
}



// 对纹理采样的数据
void SampleTexData_float
(
// 输入参数
    float3 _Info,
    float2 _ScreenPos,
    float _Blur,
    float _TwistForce,
// 输出参数
    out float4 _SampleUVPos,
    out float _MipmapLv
)
{
    _SampleUVPos = float4(_ScreenPos.xy + _Info.xy * _TwistForce, 0, 1);
    _MipmapLv= _Blur * ( 1 - _Info.z ); // 由于 _Info.z 表示的是雨滴下滑时产生的水痕，值范围是[0,1]。1表示完全是水痕，相当于将雾蒙蒙擦拭。0表示没有水痕，完全是雾化状态。blur表示纹理mipmap采样等级。范围[0,7]
}



#endif //镜面的雨滴效果（由 Graphi 着色库工具生成）| 作者：强辰