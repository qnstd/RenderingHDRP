using Unity.Plastic.Newtonsoft.Json.Serialization;
using UnityEditor;
using UnityEditor.Rendering;
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
                m_TitleStyle = new GUIStyle("AC BoldHeader") { richText = true, fontSize = 11, alignment = TextAnchor.MiddleLeft, contentOffset = new Vector2(30, -1) };
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
            Rect rect = GUILayoutUtility.GetRect(new GUIContent(title), m_TitleStyle, Gui.W(4000), Gui.H(25));
            rect.x = 0;
            GUI.Box(rect, title, m_TitleStyle);

            var toggleRect = new Rect(rect.x + 16f, rect.y + 5f, 13f, 13f); // foldout 三角形状的区域
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

            m_Foldout = Foldout(m_Foldout, "<color=#cefff9>Rendering Parameters</color>");
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
        /// <param name="usePropName">在参数label为空的情况下，此值为true，则使用属性名称，否则设置为空字符</param>
        protected void DrawShaderProperty(string propName, string label = "", bool usePropName = true)
        {
            string s = string.IsNullOrEmpty(label) ? (usePropName ? propName : "") : label;
            m_Editor.ShaderProperty(FindProperty(propName, m_Props), s);
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
            foldout = EditorGUILayout.Foldout(foldout, label, true);
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
        /// 绘制贴图（单行模式，不带TillingAndOffset）
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawTex(string label, string pname)
        {
            m_Editor.TexturePropertySingleLine
                (
                    new GUIContent(label),
                    FindProp(pname)
                );
        }

        /// <summary>
        /// 绘制贴图（单行模式，不带TillingAndOffset）
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname1"></param>
        /// <param name="pname2"></param>
        protected void DrawTex(string label, string pname1, string pname2)
        {
            m_Editor.TexturePropertySingleLine
                (
                    new GUIContent(label),
                    FindProp(pname1),
                    FindProp(pname2)
                );
        }


        /// <summary>
        /// 绘制范围的Slider组件
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawRange(string label, string pname)
        {
            m_Editor.RangeProperty(FindProp(pname), label);
        }



        /// <summary>
        /// 绘制范围的Slider组件（int类型）
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawIntRange(string label, string pname, string tooltip = null)
        {
            m_Editor.IntSliderShaderProperty(FindProp(pname), EditorGUIUtility.TrTextContent(label, tooltip));
        }


        /// <summary>
        /// 绘制 Vector3 类型的着色属性
        /// <para>在 shader 声明为 vector 类型的属性，实际是 Vector3 类型。因此，在 Inspector 检视板内需要将显示改为 vector3 类型。</para>
        /// </summary>
        /// <param name="prop"></param>
        /// <param name="desc"></param>
        protected void DrawVector3(string prop, string desc)
        {
            m_Editor.Vector3ShaderProperty(FindProp(prop), new GUIContent(desc));
        }


        /// <summary>
        /// 绘制组合模式的Slider组件（可主动调节最大最小值）
        /// </summary>
        /// <param name="minprop"></param>
        /// <param name="maxprop"></param>
        /// <param name="min"></param>
        /// <param name="max"></param>
        /// <param name="desc"></param>
        protected void DrawMaxMinSlider(string minprop, string maxprop, float min, float max, string desc)
        {
            m_Editor.MinMaxShaderProperty
                (
                    FindProp(minprop),
                    FindProp(maxprop),
                    min,
                    max,
                    new GUIContent(desc)
                );
        }

        /// <summary>
        /// 绘制组合模式的Slider组件（可主动调节最大最小值）
        /// </summary>
        /// <param name="prop"></param>
        /// <param name="min"></param>
        /// <param name="max"></param>
        /// <param name="desc"></param>
        protected void DrawMaxMinSlider(string prop, float min, float max, string desc)
        {
            m_Editor.MinMaxShaderProperty
                (
                    FindProp(prop),
                    min,
                    max,
                    new GUIContent(desc)
                );
        }


        /// <summary>
        /// 扩展属性的绘制（子类实现）
        /// </summary>
        protected virtual void ExtensionProps() { }


    }
}