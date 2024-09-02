using UnityEngine;

namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// 编辑模式下数据的缓存
    /// <para>作者：强辰</para>
    /// </summary>
    public class CacheData
    {
        /// <summary>
        /// 缓存的key
        /// </summary>
        static string[] Keys = new string[]
        {
            // 第一次启动 Unity 
            "Graphi_FirstRunUnity",
        };



        static public void SetFirstRunUnity(int val)
        {
            PlayerPrefs.SetInt(Keys[0], val);
        }
        static public int GetFirstRunUnity { get { return PlayerPrefs.GetInt(Keys[0]); } }

    }

}