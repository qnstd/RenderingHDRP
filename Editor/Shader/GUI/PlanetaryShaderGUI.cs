namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ����ͨ����ɫ�����Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class PlanetaryShaderGUI : ShaderGraphGUI
    {
        FresnelLightShaderGUI fresnelGUI = new FresnelLightShaderGUI();


        protected override void ExtensionProps()
        {
            Gui.Label("����");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("����"), FindProperty(ShaderPropIDs.ID_AlbedoTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoColor, "");
            Gui.EndHor();
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("����"), FindProperty(ShaderPropIDs.ID_NormalTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_NormalStrength, "");
            Gui.EndHor();
            DrawShaderProperty(ShaderPropIDs.ID_TriUVTile, "��Ƭ");
            DrawShaderProperty(ShaderPropIDs.ID_TriBlendWeight, "����Ȩ��");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            Gui.Label("ϸ��");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("����R���Ҷȡ�G�����֡�B��ƽ���ȣ�"), FindProperty(ShaderPropIDs.ID_DetailTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_DetailColor, "");
            Gui.EndHor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("����"), FindProperty(ShaderPropIDs.ID_DetailNormalTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_DetailUVTile, "��Ƭ");
            DrawShaderProperty(ShaderPropIDs.ID_DetailBlendWeight, "����Ȩ��");
            DrawShaderProperty(ShaderPropIDs.ID_DetailAlbedoScal, "����ǿ��");
            DrawShaderProperty(ShaderPropIDs.ID_DetailNormalScal, "����ǿ��");
            DrawShaderProperty(ShaderPropIDs.ID_DetailSmoothnessScal, "ƽ����ǿ��");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            Gui.Label("PBR");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawShaderProperty(ShaderPropIDs.ID_Metallic, "������");
            DrawShaderProperty(ShaderPropIDs.ID_Smooth, "ƽ����");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            fresnelGUI.Draw(m_Editor, m_Props);
        }
    }

}

