using Unity.Plastic.Newtonsoft.Json.Serialization;
using UnityEditor;
using UnityEditor.Rendering.HighDefinition;
using UnityEngine;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ShaderGraph ����������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class ShaderGraphGUI : LightingShaderGraphGUI
    {
        /// <summary>
        /// ������ʽ
        /// </summary>
        protected GUIStyle m_TitleStyle = null;
        protected void TitleStyle()
        {
            if (m_TitleStyle == null)
                m_TitleStyle = new GUIStyle("ObjectFieldThumb") { richText = true, fontSize = 11, contentOffset = new Vector2(30, 0) };
        }


        // �Զ���������ʾ����
        protected bool m_Foldout = true;
        /// <summary>
        /// �����Զ���Foldout���
        /// </summary>
        /// <param name="b"></param>
        /// <param name="title"></param>
        /// <returns></returns>
        protected bool Foldout(bool b, string title)
        {
            Rect rect = GUILayoutUtility.GetRect(new GUIContent(title), m_TitleStyle, Gui.W(4000), Gui.H(18));
            rect.x = 0;
            GUI.Box(rect, title, m_TitleStyle);

            var toggleRect = new Rect(rect.x + 16f, rect.y + 3f, 13f, 13f); // foldout ������״������
            var e = Event.current;
            if (e.type == EventType.Repaint)
            {
                EditorStyles.foldout.Draw(toggleRect, false, false, b, false);
            }
            if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))
            {
                b = !b;
                e.Use();
            }
            return b;
        }


        protected MaterialEditor m_Editor;
        protected MaterialProperty[] m_Props;


        /// <summary>
        /// ����
        /// </summary>
        public ShaderGraphGUI()
        {
            // �޸ĸ���Ĳ��ʿ�ע�������ֻ��������ѡ����߼�ѡ�������ȫ���Ƴ�
            //uiBlocks.Insert(1, new TransparencyUIBlock(MaterialUIBlock.ExpandableBit.Transparency, TransparencyUIBlock.Features.Refraction));
            uiBlocks.RemoveRange(1, 2);
        }


        /// <summary>
        /// ����������
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="props"></param>
        protected override void OnMaterialGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            // ������Ļ��Ʊ���
            base.OnMaterialGUI(materialEditor, props);

            m_Props = props;
            m_Editor = materialEditor;

            TitleStyle();

            m_Foldout = Foldout(m_Foldout, "<color=#86ff3d>Custom Renderer Data</color>");
            if (m_Foldout)
            {
                Gui.Space(3);

                // ������Զ�������
                ExtensionProps();

                Gui.Space(3);
            }
        }


        /// <summary>
        /// ��������
        /// </summary>
        /// <param name="propName">����ID</param>
        /// <param name="label">��ǩ</param>
        protected void DrawShaderProperty(string propName, string label = "")
        {
            m_Editor.ShaderProperty(FindProperty(propName, m_Props), label);
        }


        /// <summary>
        /// ��ȡ����
        /// </summary>
        /// <param name="propname"></param>
        /// <returns></returns>
        protected MaterialProperty FindProp(string propname) { return FindProperty(propname, m_Props); }


        /// <summary>
        /// ����Foldout��
        /// </summary>
        /// <param name="foldout"></param>
        /// <param name="label"></param>
        /// <param name="action"></param>
        protected void FoldoutGroup(ref bool foldout, string label, Action action)
        {
            foldout = EditorGUILayout.Foldout(foldout, label);
            if (foldout)
            {
                Gui.Space(5);
                Gui.IndentLevelAdd();
                action?.Invoke();
                Gui.IndentLevelSub();
                Gui.Space(5);
            }
        }



        /// <summary>
        /// ��չ���ԵĻ��ƣ�����ʵ�֣�
        /// </summary>
        protected virtual void ExtensionProps() { }


    }
}