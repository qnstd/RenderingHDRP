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
            m_Editor.TexturePropertyWithHDRColor(new UnityEngine.GUIContent("Tex"), FindProp(ShaderPropIDs.ID_AlbedoTex), FindProp(ShaderPropIDs.ID_AlbedoColor), true);
            Gui.Space(3);
            DrawShaderProperty("_OutRing", "Out ring");
            DrawShaderProperty("_InnerRing", "inner ring");
            DrawShaderProperty("_RingPow", "Ring pow");
            DrawShaderProperty(ShaderPropIDs.ID_Force, "Force");
        }
    }

}