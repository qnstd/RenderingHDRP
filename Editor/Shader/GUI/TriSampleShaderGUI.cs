using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 三向采样检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class TriSampleShaderGUI : NodeShaderGUI
    {
        /// <summary>
        /// 三向采样类型
        /// </summary>
        public enum TriSampleType
        {
            /// <summary>
            /// 通用纹理
            /// </summary>
            General,
            /// <summary>
            /// 法线类型
            /// </summary>
            Normal
        }


        // 类型
        TriSampleType m_Type = TriSampleType.General;
        string m_Label = string.Empty;


        /// <summary>
        /// 构造
        /// </summary>
        /// <param name="typ">三向采样类型</param>
        /// <param name="label">标题</param>
        public TriSampleShaderGUI(TriSampleType typ = TriSampleType.General, string label = "")
        {
            m_Type = typ;
            m_Label = label;
        }


        /// <summary>
        /// 绘制
        /// </summary>
        /// <param name="editor"></param>
        /// <param name="props"></param>
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            if (m_Type == TriSampleType.General)
            {
                Gui.Label((string.IsNullOrEmpty(m_Label) ? "TriDefaultSample" : m_Label));
                Gui.IndentLevelAdd();
                Gui.Space(3);
                Gui.Hor();
                DrawTex("Tex", ShaderPropIDs.ID_AlbedoTex, editor, props);
                DrawDefault(ShaderPropIDs.ID_AlbedoColor, "", editor, props);
                Gui.EndHor();
                DrawDefault(ShaderPropIDs.ID_AlbedoUVTile, "Tile", editor, props);
                DrawDefault(ShaderPropIDs.ID_AlbedoTriBlendWeight, "Blend Weight", editor, props);
                Gui.Space(3);
                Gui.IndentLevelSub();
            }
            else
            {
                Gui.Label((string.IsNullOrEmpty(m_Label) ? "TriNormalSample" : m_Label));
                Gui.IndentLevelAdd();
                Gui.Space(3);
                DrawTex("Tex", ShaderPropIDs.ID_NormalTex, editor, props);
                DrawDefault(ShaderPropIDs.ID_NormalStrength, "Force", editor, props);
                DrawDefault(ShaderPropIDs.ID_NormalUVTile, "Tile", editor, props);
                DrawDefault(ShaderPropIDs.ID_NormalTriBlendWeight, "Blend Weight", editor, props);
                Gui.Space(3);
                Gui.IndentLevelSub();
            }
        }

    }
}