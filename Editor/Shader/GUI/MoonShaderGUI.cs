using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ������ɫ�����Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class MoonShaderGUI : ShaderGraphGUI
    {

        TriSampleShaderGUI normalTriGUI = new TriSampleShaderGUI(TriSampleShaderGUI.TriSampleType.Normal, "����");


        protected override void ExtensionProps()
        {
            Gui.Label("������ & ϸ��");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertySingleLine
                (
                    new GUIContent("����R�������ʣ�G��ϸ�ڣ�"),
                    FindProperty(ShaderPropIDs.ID_AlbedoTex, m_Props)
                );
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoColor, "��������ɫ");
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoUVTile, "������UV��Ƭ");
            DrawShaderProperty(ShaderPropIDs.ID_DetailColor, "ϸ����ɫ");
            DrawShaderProperty(ShaderPropIDs.ID_DetailUVTile, "ϸ��UV��Ƭ");
            DrawShaderProperty(ShaderPropIDs.ID_DetailPow, "ϸ��ָ��");
            DrawShaderProperty(ShaderPropIDs.ID_DetailForce, "ϸ��ǿ��");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            normalTriGUI.Draw(m_Editor, m_Props);


            Gui.Space(5);
            DrawShaderProperty(ShaderPropIDs.ID_Metallic, "������");
            DrawShaderProperty(ShaderPropIDs.ID_Smooth, "ƽ����");
        }

    }
}