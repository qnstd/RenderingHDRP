#ifndef GNOISE
#define GNOISE


// //////////////////////////////////////////////////
// 相关技术文档链接
//      Perlin Noise : https://adrianb.io/2014/08/09/perlinnoise.html

// //////////////////////////////////////////////////




// ///////////////////////////////////////
// 计算 Perlin Noise 噪声
// ///////////////////////////////////////

float2 PerlinNoiseRandom(float2 i)
{
    // 公式：-1 + 2 * frac(sin( float2( dot(i * offset), dot(i * offset)) ) * n)
    return -1 + 2 * frac(sin(float2(dot(i, float2(127.1,311.7)),dot(i, float2(269.5,183.3)))) * 43758.5453123);
}

float CalculatePerlinNoise(float2 uv, float uvTile)
{
    uv *= uvTile;
    float2 index = floor(uv);
    float2 coordinate= frac(uv);

    //缓和曲线
    //  公式：
    //      t = frac(uv)
    //      u = t * t * ( 3 - 2 * t )
    float2 u = coordinate * coordinate * ( 3 - 2 * coordinate);

    //四个角的随机向量投影（Ken Perlin （Perlin Noise）噪声）
    float buttomLeft = dot(PerlinNoiseRandom(index), coordinate - float2(0,0));
    float buttomRight = dot(PerlinNoiseRandom(index  + float2(1,0)), coordinate - float2(1,0));
    float topLeft = dot(PerlinNoiseRandom(index  + float2(0,1)), coordinate - float2(0,1));
    float topRight = dot(PerlinNoiseRandom(index  + float2(1,1)), coordinate - float2(1,1));

    //获取插值
    //  公式：
    //      value = lerp( lerp(bl, br, u.x), lerp(tl, tr, u.x), u.y )
    float value = lerp(lerp(buttomLeft ,buttomRight ,u.x), lerp(topLeft ,topRight ,u.x), u.y);
    value = value * 0.5 + 0.5;

    return value;
}




// ///////////////////////////////////////
// 计算 Worley Noise 噪声
// ///////////////////////////////////////

float2 WorleyNoiseRandom(float2 p)
{
    return frac(sin(float2(dot(p, float2(127.1,311.7)),dot(p, float2(269.5,183.3))))*43758.5453);
}

// 标准 WorleyNoise 
float CalculateWorleyNoise(float2 uv, float uvTile)
{
    uv *= uvTile;
    float2 index = floor(uv);
    float2 coordinate= frac(uv);

    float noise = 1;
    for ( int m = -1; m <= 1; m++ )
    {
        for ( int n = -1; n <= 1; n++ )
        {
            float2 p = index + float2( m, n ); // 获取周围的9个点
            
            // 计算点的偏移（利用噪声）距离，将偏移结果与点相加得到最终的点
            p += WorleyNoiseRandom( p );

            // 计算点与原始uv的距离，并于最小距离进行取最小值
            noise = min(noise, distance(uv, p));
        }
    }
    return noise;
}

// 变换 WorleyNoise 。其中 typ 为变换类型，参数值范围：[0-2]。其中 0代表的效果与标准 WorleyNoise 一致。
float CalculateWorleyNoise_Transform(float2 uv, float uvTile, float typ = 0)
{
    uv *= uvTile;
    float2 index = floor(uv);
    float2 coordinate= frac(uv);

    float2 noise = float2(1, 1);
    for ( int m = -1; m <= 1; m++ )
    {
        for ( int n = -1; n <= 1; n++ )
        {
            float2 p = index + float2( m, n ); // 获取周围的9个点
            
            // 计算点的偏移（利用噪声）距离，将偏移结果与点相加得到最终的点
            p += WorleyNoiseRandom( p );

            // 计算点与原始uv的距离
            float dist = distance(uv, p);

            // 储存距离最近与第2近的值
            if(dist < noise.x)
            {
                noise.y = noise.x;
                noise.x = dist;
            }
            else
            {
                noise.y = min(dist, noise.y);
            }
        }
    }

    float n = noise.x;
    if(typ == 1)
        n = noise.y - noise.x;
    else if(typ == 2)
        n = noise.y * noise.x;

    return  n;
}




// ///////////////////////////////////////
// 计算 FBM Noise 噪声
// ///////////////////////////////////////

float FbmNoiseRandom(float2 i)
{
    return frac( sin(dot(i, float2(12.9898, 78.233))) * 43758.5453123 );
}

float FbmNoise(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);

    float a = FbmNoiseRandom(i);
    float b = FbmNoiseRandom(i + float2(1.0, 0.0));
    float c = FbmNoiseRandom(i + float2(0.0, 1.0));
    float d = FbmNoiseRandom(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float CalculateFbmNoise(float2 uv, float tile)
{
    uv *= tile;

    float noise = 0.0;
    float amplitude = 0.5;
    float frequency = 0.0;

    // 8度循环
    for (int i = 0; i < 8; i++) 
    {
        noise += amplitude * FbmNoise(uv);
        uv *= 2.0;
        amplitude *= 0.5;
    }
    return noise;
}


#endif //噪声计算（由 Graphi 着色库工具生成）| 作者：强辰