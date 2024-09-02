namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ̫����ɫ�����Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class SunShaderGUI : ShaderGraphGUI
    {

        FresnelShaderGUI fresnelGUI = new FresnelShaderGUI();

        protected override void ExtensionProps()
        {
            Gui.Label("����");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("����R�����ϸ�ڣ�G���ڲ�ϸ�ڣ�B�����ϸ�ڵ�Ť��������"), FindProperty(ShaderPropIDs.ID_MixedTex, m_Props));
            DrawShaderProperty("_SurfaceRTile", "����Rͨ���ֲ�");
            DrawShaderProperty("_SurfaceGTile", "����Gͨ���ֲ�");
            DrawShaderProperty("_SurfaceSamplePow", "�������ָ��");
            DrawShaderProperty("_RFloatSpeed", "Rͨ�������ٶ�");
            DrawShaderProperty(ShaderPropIDs.ID_TwistUVTile, "Ť������ֲ�");
            DrawShaderProperty(ShaderPropIDs.ID_TwistSpeed, "Ť���ٶ�");
            DrawShaderProperty(ShaderPropIDs.ID_TwistForce, "Ť��ǿ��");
            DrawShaderProperty("_BottomColor", "�����ɫ");
            DrawShaderProperty("_TopColor", "�ڲ���ɫ");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            fresnelGUI.Draw(m_Editor, m_Props);


            Gui.Space(5);
            Gui.Label("����");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawShaderProperty("_VertexFresnelPow", "����ڶ�ָ��");
            DrawShaderProperty(ShaderPropIDs.ID_Amplitude, "���");
            DrawShaderProperty("_Speed", "�����ٶ�");
            DrawShaderProperty("_Tile", "�ֲ�");
            Gui.Space(3);
            Gui.IndentLevelSub();
        }
    }

}