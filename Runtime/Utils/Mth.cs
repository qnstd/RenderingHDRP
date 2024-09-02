using System;
using System.Text;

namespace com.graphi.renderhdrp
{

    /// <summary>
    /// ��ѧ��
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class Mth
    {
        /// <summary>
        /// �������Լ��
        /// </summary>
        /// <param name="a">intֵ1</param>
        /// <param name="b">intֵ2</param>
        /// <returns></returns>
        static public uint CalculateGCD(uint a, uint b)
        {
            uint remainder;
            while (b != 0)
            {
                remainder = a % b;
                a = b;
                b = remainder;
            }
            return a;
        }



        /// <summary>
        /// �����Ƿ���2����
        /// </summary>
        /// <returns></returns>
        static public bool IntIsApowof2(int val)
        {
            return (val > 0) && (val & (val - 1)) == 0;
        }



        /// <summary>
        /// ��������
        /// </summary>
        /// <param name="x">�����ʹ�õ�ֵ</param>
        /// <param name="y">�����ʹ�õķ���</param>
        /// <returns></returns>
        static public float CopySign(float x, float y)
        {
            float val = Math.Abs(x);

            int sign = MathF.Sign(y);
            sign = (sign >= 0) ? 1 : sign;

            return val * sign;
        }


        /// <summary>
        /// �����
        /// </summary>
        /// <param name="length">���������</param>
        /// <returns></returns>
        public static string GenerateRandomNum(int length)
        {
            StringBuilder result = new StringBuilder();
            for (var i = 0; i < length; i++)
            {
                var r = new System.Random(Guid.NewGuid().GetHashCode());
                result.Append(r.Next(0, 10));
            }
            return result.ToString();
        }
    }

}