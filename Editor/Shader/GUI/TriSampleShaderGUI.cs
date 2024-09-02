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
                Gui.Label((string.IsNullOrEmpty(m_Label) ? "三向反照率采样" : m_Label));
                Gui.IndentLevelAdd();
                Gui.Space(3);
                Gui.Hor();
                DrawTex("纹理", ShaderPropIDs.ID_AlbedoTex, editor, props);
                DrawDefault(ShaderPropIDs.ID_AlbedoColor, "", editor, props);
                Gui.EndHor();
                DrawDefault(ShaderPropIDs.ID_AlbedoUVTile, "瓦片", editor, props);
                DrawDefault(ShaderPropIDs.ID_AlbedoTriBlendWeight, "混合权重", editor, props);
                Gui.Space(3);
                Gui.IndentLevelSub();
            }
            else
            {
                Gui.Label((string.IsNullOrEmpty(m_Label) ? "三向法线采样" : m_Label));
                Gui.IndentLevelAdd();
                Gui.Space(3);
                DrawTex("纹理", ShaderPropIDs.ID_NormalTex, editor, props);
                DrawDefault(ShaderPropIDs.ID_NormalStrength, "强度", editor, props);
                DrawDefault(ShaderPropIDs.ID_NormalUVTile, "瓦片", editor, props);
                DrawDefault(ShaderPropIDs.ID_NormalTriBlendWeight, "混合权重", editor, props);
                Gui.Space(3);
                Gui.IndentLevelSub();
            }
        }

    }
}