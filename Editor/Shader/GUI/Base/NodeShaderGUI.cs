using UnityEngine;

using UnityEditor;
using UnityEditor.Rendering;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// �ӿ�
    /// </summary>
    public interface INodeShaderGUI
    {
        void Draw(MaterialEditor editor, MaterialProperty[] props);
    }



    /// <summary>
    /// ShaderGraph �ڵ� ShaderGUI ����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class NodeShaderGUI : ShaderGUI, INodeShaderGUI
    {
        /// <summary>
        /// ����ʵ��
        /// </summary>
        /// <param name="editor"></param>
        /// <param name="props"></param>
        public virtual void Draw(MaterialEditor editor, MaterialProperty[] props) { }


        /// <summary>
        /// ��������
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
        /// ���������ǲ��ǿ�ֵ
        /// </summary>
        /// <param name="pname"></param>
        /// <param name="props"></param>
        /// <returns></returns>
        protected bool IsNullTex(string pname, MaterialProperty[] props)
        {
            return Find(pname, props).textureValue == null;
        }



        /// <summary>
        /// Ĭ�ϻ���
        /// </summary>
        /// <param name="pname"></param>
        /// <param name="label"></param>
        protected void DrawDefault(string pname, string label, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.ShaderProperty(Find(pname, props), new GUIContent(label));
        }


        /// <summary>
        /// ������ͼ������ģʽ������TillingAndOffset��
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
        /// ������ͼ������ģʽ������TillingAndOffset��
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
        /// ���Ʒ�Χ��Slider���
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawRange(string label, string pname, MaterialEditor editor, MaterialProperty[] props)
        {
            editor.RangeProperty(FindProperty(pname, props), label);
        }



        /// <summary>
        /// ���Ʒ�Χ��Slider�����int���ͣ�
        /// </summary>
        /// <param name="label"></param>
        /// <param name="pname"></param>
        protected void DrawIntRange(string label, string pname, MaterialEditor editor, MaterialProperty[] props, string tooltip = null)
        {
            editor.IntSliderShaderProperty(FindProperty(pname, props), EditorGUIUtility.TrTextContent(label, tooltip));
        }


        /// <summary>
        /// �������ģʽ��Slider��������������������Сֵ��
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
        /// �������ģʽ��Slider��������������������Сֵ��
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