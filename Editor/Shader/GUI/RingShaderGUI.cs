namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 光环着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class RingShaderGUI : ShaderGraphGUI
    {
        protected override void ExtensionProps()
        {
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("纹理"), FindProperty(ShaderPropIDs.ID_AlbedoTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoColor);
            Gui.EndHor();
            Gui.Space(3);
            DrawShaderProperty("_OutRing", "外环");
            DrawShaderProperty("_InnerRing", "内环");
            DrawShaderProperty("_RingPow", "边缘指数");
            DrawShaderProperty(ShaderPropIDs.ID_Force, "强度");
        }
    }

}