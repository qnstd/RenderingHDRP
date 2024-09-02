using Unity.Mathematics;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ƽ�湤�߰�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class PlaneUtils
    {

        /// <summary>
        /// ���߼�����һ�㹹��ƽ��
        /// </summary>
        /// <param name="n">����</param>
        /// <param name="p">����һ��</param>
        static public Vector4 BuildPlane(Vector3 n, Vector3 p)
        {
            // ƽ�淽�̣�A*x + B*y + C*z + D = 0
            return new Vector4(n.x, n.y, n.z, -VectorUtils.Dot(n, p));
        }




        /// <summary>
        /// ����λ�ù���һ��ƽ��
        /// </summary>
        /// <param name="p1">��1</param>
        /// <param name="p2">��2</param>
        /// <param name="p3">��3</param>
        static public Vector4 BuildPlane(Vector3 p1, Vector3 p2, Vector3 p3)
        {
            Vector3 p21 = p2 - p1;
            Vector3 p31 = p3 - p1;
            Vector3 n = math.normalize(VectorUtils.Cross(p21, p31));
            return BuildPlane(n, p1);
        }



        /// <summary>
        /// ����ƽ��ķ�λ
        /// </summary>
        /// <param name="point">�����</param>
        /// <param name="plane">ƽ��</param>
        /// <returns>
        ///     0��ƽ���� <br></br>
        ///     ����0��ƽ���⣨ƽ������棩<br></br>
        ///     С��0��ƽ���ڣ�ƽ��ķ��棩
        /// </returns>
        static public float PointAzimuthWithPlane(Vector3 point, Vector4 plane)
        {
            /* 
                dot = |a|*|b|*cos�ȡ�
                �� cos ֵ > 0���н�Ϊ��ǣ���ͬ����
                �� cos ֵ < 0���н�Ϊ�۽ǣ��ڷ�����
                �� cos ֵ = 0���н�Ϊ0����ƽ���ϣ�

                ��ƽ��ķ��߷���Ϊ������Ҳ����ƽ���������˵����� cos ֵ > 0��˵����ƽ��֮�⡣��֮������ƽ��֮�ڣ�Ҳ���Ǳ��档
            */
            return VectorUtils.Dot(new Vector3(plane.x, plane.y, plane.z), point) + plane.w;
        }




        /// <summary>
        /// ƽ�����Ƿ���ڵ�
        /// </summary>
        /// <param name="point">��</param>
        /// <param name="plane">ƽ��</param>
        /// <returns>true�����ڣ�false��������</returns>
        static public bool PointOnPlane(Vector3 point, Vector4 plane)
        {
            return PointAzimuthWithPlane(point, plane) == 0;
        }
    }
}