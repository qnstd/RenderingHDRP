using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ����������Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class TriSampleShaderGUI : NodeShaderGUI
    {
        /// <summary>
        /// �����������
        /// </summary>
        public enum TriSampleType
        {
            /// <summary>
            /// ͨ������
            /// </summary>
            General,
            /// <summary>
            /// ��������
            /// </summary>
            Normal
        }


        // ����
        TriSampleType m_Type = TriSampleType.General;
        string m_Label = string.Empty;


        /// <summary>
        /// ����
        /// </summary>
        /// <param name="typ">�����������</param>
        /// <param name="label">����</param>
        public TriSampleShaderGUI(TriSampleType typ = TriSampleType.General, string label = "")
        {
            m_Type = typ;
            m_Label = label;
        }


        /// <summary>
        /// ����
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