using UnityEngine;

using UnityEditor;
using UnityEditor.Rendering;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 接口
    /// </summary>
    public interface INodeShaderGUI
    {
        void Draw(MaterialEditor editor, MaterialProperty[] props);
    }



    /// <summary>
    /// ShaderGraph 节点 ShaderGUI 基类
    /// <para>作者：强辰</para>
    /// </summary>
    public class NodeShaderGUI : ShaderGUI, INodeShaderGUI
    {
        /// <summary>
        /// 子类实现
        /// </summary>
        /// <param name="editor"></param>
        /// <param name="props"></param>
        public virtual void Draw(MaterialEditor editor, MaterialProperty[] props) { }


        /// <summary>
        /// 查找属性
        /// </summary>
        /// <param name="propname"></param>
        /// <param name="props"></param>
        /// <returns></returns>
        protected MaterialProperty Find(string propname, MaterialProperty[] props)
        {
            if (string.IsNullOrEmpty(propname) || props == null) { return null; }
            return FindProperty(propname, props);
        }


        /// <summary>
        /// 纹理属性是不是空值
        /// </summary>
        /// <param name="pname"></param>
        /// <param name="props"></param>
        /// <returns></returns>
        protected bool IsNullTex(string pname, MaterialProperty[] props)
        {
            return Find(pname, props).textureValue == null;
        }



        /// <summary>
        /// 默认绘制
        /// </summary>
        /// <param name="pname"></param>
        /// <param name="label"></param>
        protected void DrawDefault(string pname, string label, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.ShaderProperty(Find(pname, props), new GUIContent(label));
        }


        /// <summary>
        /// 绘制贴图（单行模式，不带TillingAndOffset）
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawTex(string label, string pname, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.TexturePropertySingleLine
                (
                    new GUIContent(label),
                    Find(pname, props)
                );
        }

        /// <summary>
        /// 绘制贴图（单行模式，不带TillingAndOffset）
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname1"></param>
        /// <param name="pname2"></param>
        protected void DrawTex(string label, string pname1, string pname2, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.TexturePropertySingleLine
                (
                    new GUIContent(label),
                    Find(pname1, props),
                    Find(pname2, props)
                );
        }



        /// <summary>
        /// 绘制范围的Slider组件
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawRange(string label, string pname, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.RangeProperty(FindProperty(pname, props), label);
        }



        /// <summary>
        /// 绘制范围的Slider组件（int类型）
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawIntRange(string label, string pname, MaterialEditor editor, MaterialProperty[] props, string tooltip = null)
        {
            editor.IntSliderShaderProperty(FindProperty(pname, props), EditorGUIUtility.TrTextContent(label, tooltip));
        }


        /// <summary>
        /// 绘制组合模式的Slider组件（可主动调节最大最小值）
        /// </summary>
        /// <param name="minprop"></param>
        /// <param name="maxprop"></param>
        /// <param name="min"></param>
        /// <param name="max"></param>
        /// <param name="desc"></param>
        protected void DrawMaxMinSlider(string minprop, string maxprop, float min, float max, string desc, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.MinMaxShaderProperty
                (
                    FindProperty(minprop, props),
                    FindProperty(maxprop, props),
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
        protected void DrawMaxMinSlider(string prop, float min, float max, string desc, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.MinMaxShaderProperty
                (
                    FindProperty(prop, props),
                    min,
                    max,
                    new GUIContent(desc)
                );
        }
    }
}