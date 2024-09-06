namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// �ü���ɫ��ɫ�����Ӱ�
    /// <para>���ߣ�ǿ��</para>
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


