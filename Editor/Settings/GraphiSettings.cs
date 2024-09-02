using UnityEditor;

namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// Graphi ��ɫ�� Editor �����µ����ù���
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class GraphiSettings
    {
        /// <summary>
        /// ȫ��������
        /// <para>����</para>
        /// </summary>
        static public GlobalDataSettings GlobalSettings { get; private set; } = null;


        /// <summary>
        /// ��������������
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