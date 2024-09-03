using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 法线空间
    /// </summary>
    public enum NormalSpace
    {
        /// <summary>
        /// 世界空间
        /// </summary>
        World = 1,
        /// <summary>
        /// 视空间
        /// </summary>
        View
    }


    /// <summary>
    /// Graphi 着色库全局数据配置
    /// <para>作者：强辰</para>
    /// </summary>
    [CreateAssetMenu(fileName = "GlobalDataSettingsAsset", menuName = "Rendering/Graphi EditorGlobalSettings", order = 0)]
    public class GlobalDataSettings : ScriptableObject
    {
        public Color m_GeometryColor = Color.white;
        public float m_GeometryNormalLength = 0.1f;
        public NormalSpace m_GeometryNormalSpace = NormalSpace.World;
        public bool m_PushDialogAbout = true;

        // 纹理资源的文件名后缀标识符
        public string m_NormalTexTag = "_n";
        public string m_UiTexTag = "_ui";
    }




    /// <summary>
    /// 序列化数据对象的Inspector优化
    /// <para>作者：强辰</para>
    /// </summary>
    [CustomEditor(typeof(GlobalDataSettings))]
    internal class GlobalDataSettingsEditor : UnityEditor.Editor
    {
        GlobalDataSettings m_src;

        bool m_GeometryFlag = true;
        bool m_NormalFlag = true;
        SerializedProperty m_GeometryColor;
        SerializedProperty m_GeometryNormalLength;
        SerializedProperty m_GeometryNormalSpace;

        bool m_TexFlag = true;
        bool m_TexAssetFlag = true;
        SerializedProperty m_NormalTexTag;
        SerializedProperty m_UiTexTag;

        bool m_OtherFlag = true;
        SerializedProperty m_PushDialogAbout;


        private void OnEnable()
        {
            m_src = (GlobalDataSettings)target;

            m_GeometryColor = serializedObject.FindProperty("m_GeometryColor");
            m_GeometryNormalLength = serializedObject.FindProperty("m_GeometryNormalLength");
            m_GeometryNormalSpace = serializedObject.FindProperty("m_GeometryNormalSpace");

            m_NormalTexTag = serializedObject.FindProperty("m_NormalTexTag");
            m_UiTexTag = serializedObject.FindProperty("m_UiTexTag");

            m_PushDialogAbout = serializedObject.FindProperty("m_PushDialogAbout");
        }



        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            #region 几何渲染
            Gui.Space(10);
            m_GeometryFlag = EditorGUILayout.Foldout(m_GeometryFlag, "Geometric rendering");
            if (m_GeometryFlag)
            {
                Gui.Space(5);
                Gui.IndentLevelAdd();

                Gui.Vertical("helpbox");
                Gui.Space(5);
                
                Gui.Check();
                EditorGUILayout.PropertyField(m_GeometryColor, new GUIContent("General Color"));
                Gui.Space(5);

                m_NormalFlag = EditorGUILayout.Foldout(m_NormalFlag, "Normal");
                if(m_NormalFlag)
                {
                    Gui.Space(5);
                    Gui.IndentLevelAdd();
                    EditorGUILayout.PropertyField(m_GeometryNormalLength, new GUIContent("Length"));
                    if (Gui.EndCheck())
                    {
                        m_src.m_GeometryNormalLength = m_GeometryNormalLength.floatValue;
                        GeometryOperate.Update();
                    }
                    Gui.Space(5);
                    EditorGUILayout.PropertyField(m_GeometryNormalSpace, new GUIContent("Space"));
                    if (Gui.EndCheck())
                    {
                        m_src.m_GeometryNormalSpace = (NormalSpace)m_GeometryNormalSpace.intValue;
                        GeometryOperate.Update();
                    }
                    Gui.IndentLevelSub();
                }

                Gui.Space(5);
                Gui.EndVertical();
                Gui.IndentLevelSub();
            }
            #endregion


            #region 纹理
            Gui.Space(15);
            m_TexFlag = EditorGUILayout.Foldout(m_TexFlag, "Texture");
            if (m_TexFlag)
            {
                Gui.Space(5);
                Gui.IndentLevelAdd();
                Gui.Vertical("helpbox");
                Gui.Space(5);
                m_TexAssetFlag = EditorGUILayout.Foldout(m_TexAssetFlag, "Tag");
                if (m_TexAssetFlag)
                {
                    Gui.Space(5);
                    Gui.IndentLevelAdd();
                    Gui.Label("<color=#a5ddf4>* resource file name suffix</color>", new GUIStyle() { richText = true, fontSize = 11 });
                    EditorGUILayout.PropertyField(m_NormalTexTag, new GUIContent("Normal"));
                    EditorGUILayout.PropertyField(m_UiTexTag, new GUIContent("UI"));
                    Gui.Space(3);
                    Gui.Help("Used to set the texture of the specified type at the time of import", MessageType.None);
                    Gui.IndentLevelSub();
                }
                Gui.Space(5);
                Gui.EndVertical();
                Gui.IndentLevelSub();
            }
            #endregion


            #region 其他
            Gui.Space(15);
            m_OtherFlag = EditorGUILayout.Foldout(m_OtherFlag, "Other");
            if (m_OtherFlag)
            {
                Gui.Space(5);
                Gui.IndentLevelAdd();
                Gui.Check();
                EditorGUILayout.PropertyField(m_PushDialogAbout, new GUIContent("Unity First Run Show"));
                if (Gui.EndCheck())
                {
                }
                Gui.IndentLevelSub();
            }
            #endregion

            serializedObject.ApplyModifiedProperties();
        }
    }

}