using System;
using System.Text;

namespace com.graphi.renderhdrp
{

    /// <summary>
    /// 数学库
    /// <para>作者：强辰</para>
    /// </summary>
    public class Mth
    {
        /// <summary>
        /// 计算最大公约数
        /// </summary>
        /// <param name="a">int值1</param>
        /// <param name="b">int值2</param>
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
        /// 整数是否是2的幂
        /// </summary>
        /// <returns></returns>
        static public bool IntIsApowof2(int val)
        {
            return (val > 0) && (val & (val - 1)) == 0;
        }



        /// <summary>
        /// 拷贝符号
        /// </summary>
        /// <param name="x">结果中使用的值</param>
        /// <param name="y">结果中使用的符号</param>
        /// <returns></returns>
        static public float CopySign(float x, float y)
        {
            float val = Math.Abs(x);

            int sign = MathF.Sign(y);
            sign = (sign >= 0) ? 1 : sign;

            return val * sign;
        }


        /// <summary>
        /// 随机数
        /// </summary>
        /// <param name="length">随机数长度</param>
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