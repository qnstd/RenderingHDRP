using UnityEngine.Rendering;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 标准光照变体着色器材质面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class LitStanardVariShaderGUI : ShaderGraphGUI
    {
        private LitStandardShaderGUI gui;


        public LitStanardVariShaderGUI()
        {
            gui = new LitStandardShaderGUI(PropChangeAction);
        }

        protected override void ExtensionProps()
        {
            gui.Draw(m_Editor, m_Props);
        }


        /// <summary>
        /// 标准PBR光照属性数据发生改变时触发
        /// </summary>
        /// <param name="prop1">属性名称1</param>
        /// <param name="prop2">属性名称2</param>
        protected virtual void PropChangeAction(string prop1, string prop2)
        {
            if (prop1 == ShaderPropIDs.ID_CoatTex && prop2 == ShaderPropIDs.ID_Coat)
            {
                Material material = m_Editor.target as Material;
                CoreUtils.SetKeyword(material, "_MATERIAL_FEATURE_CLEAR_COAT", material.GetFloat(ShaderPropIDs.ID_Coat) > 0.0 || material.GetTexture(ShaderPropIDs.ID_CoatTex));
            }
        }
    }
}