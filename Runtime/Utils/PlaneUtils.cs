using Unity.Mathematics;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 平面工具包
    /// <para>作者：强辰</para>
    /// </summary>
    public class PlaneUtils
    {

        /// <summary>
        /// 法线及任意一点构建平面
        /// </summary>
        /// <param name="n">法线</param>
        /// <param name="p">任意一点</param>
        static public Vector4 BuildPlane(Vector3 n, Vector3 p)
        {
            // 平面方程：A*x + B*y + C*z + D = 0
            return new Vector4(n.x, n.y, n.z, -VectorUtils.Dot(n, p));
        }




        /// <summary>
        /// 三个位置构建一个平面
        /// </summary>
        /// <param name="p1">点1</param>
        /// <param name="p2">点2</param>
        /// <param name="p3">点3</param>
        static public Vector4 BuildPlane(Vector3 p1, Vector3 p2, Vector3 p3)
        {
            Vector3 p21 = p2 - p1;
            Vector3 p31 = p3 - p1;
            Vector3 n = math.normalize(VectorUtils.Cross(p21, p31));
            return BuildPlane(n, p1);
        }



        /// <summary>
        /// 点在平面的方位
        /// </summary>
        /// <param name="point">坐标点</param>
        /// <param name="plane">平面</param>
        /// <returns>
        ///     0：平面上 <br></br>
        ///     大于0：平面外（平面的正面）<br></br>
        ///     小于0：平面内（平面的反面）
        /// </returns>
        static public float PointAzimuthWithPlane(Vector3 point, Vector4 plane)
        {
            /* 
                dot = |a|*|b|*cosθ。
                当 cos 值 > 0，夹角为锐角，在同方向；
                当 cos 值 < 0，夹角为钝角，在反方向；
                当 cos 值 = 0，夹角为0，在平面上；

                以平面的法线方向为正方向，也就是平面的正面来说，如果 cos 值 > 0，说明在平面之外。反之，则在平面之内，也就是背面。
            */
            return VectorUtils.Dot(new Vector3(plane.x, plane.y, plane.z), point) + plane.w;
        }




        /// <summary>
        /// 平面上是否存在点
        /// </summary>
        /// <param name="point">点</param>
        /// <param name="plane">平面</param>
        /// <returns>true：存在；false：不存在</returns>
        static public bool PointOnPlane(Vector3 point, Vector4 plane)
        {
            return PointAzimuthWithPlane(point, plane) == 0;
        }
    }
}