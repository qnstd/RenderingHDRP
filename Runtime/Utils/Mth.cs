using System;
using System.Text;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ��ѧ��ز���
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class Mth
    {
        /// <summary>
        /// �����Ƿ���2����
        /// </summary>
        /// <returns></returns>
        static public bool IntIsApowof2(int val)
        {
            return (val > 0) && (val & (val - 1)) == 0;
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