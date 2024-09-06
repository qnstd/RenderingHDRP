namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 裁剪颜色着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class ClipColorShaderGUI : ShaderGraphGUI
    {
        protected override void ExtensionProps()
        {
            DrawShaderProperty("_Mask", "Tex");
            Gui.Help("R: Dirt Data\nG: Scratches Data\nB: Wear Data\nA: No Wear Data", UnityEditor.MessageType.None);
            Gui.Space(3);
            DrawShaderProperty("_TintColor", "Color");
            DrawShaderProperty("_Cutoff", "Cutoff");
            DrawShaderProperty("_Dirt", "Dirt");
            DrawShaderProperty("_Wear", "Wear");
            DrawShaderProperty("_Scratches", "Scratches");
        }
    }
}


