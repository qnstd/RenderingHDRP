using Unity.Plastic.Newtonsoft.Json.Serialization;
using UnityEditor;
using UnityEditor.Rendering.HighDefinition;
using UnityEngine;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ShaderGraph 检视面板基类
    /// <para>作者：强辰</para>
    /// </summary>
    public class ShaderGraphGUI : LightingShaderGraphGUI
    {
        /// <summary>
        /// 标题样式
        /// </summary>
        protected GUIStyle m_TitleStyle = null;
        protected void TitleStyle()
        {
            if (m_TitleStyle == null)
                m_TitleStyle = new GUIStyle("ObjectFieldThumb") { richText = true, fontSize = 11, contentOffset = new Vector2(30, 0) };
        }


        // 自定义数据显示开关
        protected bool m_Foldout = true;
        /// <summary>
        /// 绘制自定义Foldout组件
        /// </summary>
        /// <param name="b"></param>
        /// <param name="title"></param>
        /// <returns></returns>
        protected bool Foldout(bool b, string title)
        {
            Rect rect = GUILayoutUtility.GetRect(new GUIContent(title), m_TitleStyle, Gui.W(4000), Gui.H(18));
            rect.x = 0;
            GUI.Box(rect, title, m_TitleStyle);

            var toggleRect = new Rect(rect.x + 16f, rect.y + 3f, 13f, 13f); // foldout 三角形状的区域
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
        /// 构造
        /// </summary>
        public ShaderGraphGUI()
        {
            // 修改父类的材质块注册表，这里只保留表面选项卡、高级选项卡，其余全部移除
            //uiBlocks.Insert(1, new TransparencyUIBlock(MaterialUIBlock.ExpandableBit.Transparency, TransparencyUIBlock.Features.Refraction));
            uiBlocks.RemoveRange(1, 2);
        }


        /// <summary>
        /// 材质面板绘制
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="props"></param>
        protected override void OnMaterialGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            // 将父类的绘制保留
            base.OnMaterialGUI(materialEditor, props);

            m_Props = props;
            m_Editor = materialEditor;

            TitleStyle();

            m_Foldout = Foldout(m_Foldout, "<color=#86ff3d>Custom Renderer Data</color>");
            if (m_Foldout)
            {
                Gui.Space(3);

                // 子类的自定义属性
                ExtensionProps();

                Gui.Space(3);
            }
        }


        /// <summary>
        /// 绘制属性
        /// </summary>
        /// <param name="propName">属性ID</param>
        /// <param name="label">标签</param>
        protected void DrawShaderProperty(string propName, string label = "")
        {
            m_Editor.ShaderProperty(FindProperty(propName, m_Props), label);
        }


        /// <summary>
        /// 获取属性
        /// </summary>
        /// <param name="propname"></param>
        /// <returns></returns>
        protected MaterialProperty FindProp(string propname) { return FindProperty(propname, m_Props); }


        /// <summary>
        /// 绘制Foldout组
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
        /// 扩展属性的绘制（子类实现）
        /// </summary>
        protected virtual void ExtensionProps() { }


    }
}