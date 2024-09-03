namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// �⻷��ɫ�����Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class RingShaderGUI : ShaderGraphGUI
    {
        protected override void ExtensionProps()
        {
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("Tex"), FindProperty(ShaderPropIDs.ID_AlbedoTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoColor);
            Gui.EndHor();
            Gui.Space(3);
            DrawShaderProperty("_OutRing", "Out ring");
            DrawShaderProperty("_InnerRing", "inner ring");
            DrawShaderProperty("_RingPow", "Ring pow");
            DrawShaderProperty(ShaderPropIDs.ID_Force, "Force");
        }
    }

}