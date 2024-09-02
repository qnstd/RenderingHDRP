using UnityEditor;

namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// Graphi 着色库 Editor 环境下的配置管理
    /// <para>作者：强辰</para>
    /// </summary>
    public class GraphiSettings
    {
        /// <summary>
        /// 全局配置项
        /// <para>杂项</para>
        /// </summary>
        static public GlobalDataSettings GlobalSettings { get; private set; } = null;


        /// <summary>
        /// 加载所有配置项
        /// </summary>
        static public void LoadAll()
        {
            GlobalSettings = load<GlobalDataSettings>("GlobalDataSettingsAsset");
        }



        private static T load<T>(string assetName) where T : UnityEngine.Object
        {
            return AssetDatabase.LoadAssetAtPath<T>(renderhdrp.Tools.FindexactFile("Editor/Settings", $"{assetName}.asset"));
        }
    }


}