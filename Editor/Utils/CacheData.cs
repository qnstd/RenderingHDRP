using UnityEngine;

namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// �༭ģʽ�����ݵĻ���
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class CacheData
    {
        /// <summary>
        /// �����key
        /// </summary>
        static string[] Keys = new string[]
        {
            // ��һ������ Unity 
            "Graphi_FirstRunUnity",
        };



        static public void SetFirstRunUnity(int val)
        {
            PlayerPrefs.SetInt(Keys[0], val);
        }
        static public int GetFirstRunUnity { get { return PlayerPrefs.GetInt(Keys[0]); } }

    }

}