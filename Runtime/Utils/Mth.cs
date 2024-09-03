using System;
using System.Text;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 数学相关操作
    /// <para>作者：强辰</para>
    /// </summary>
    public class Mth
    {
        /// <summary>
        /// 整数是否是2的幂
        /// </summary>
        /// <returns></returns>
        static public bool IntIsApowof2(int val)
        {
            return (val > 0) && (val & (val - 1)) == 0;
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