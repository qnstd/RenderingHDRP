namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// �ü�RGB��ɫ�����Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class ClipRGBShaderGUI : ShaderGraphGUI
    {
        protected override void ExtensionProps()
        {
            DrawShaderProperty("_BaseColor_Alpha", "Tex");
            DrawShaderProperty("_Mask", "Mask");
            Gui.Help("R: Dirt Data\nG: Scratches Data\nB: Wear Data\nA: No Wear Data", UnityEditor.MessageType.None);
            Gui.Space(3);
            DrawShaderProperty("_TintColor", "Color");
            DrawShaderProperty("_Cutout", "Cutoff");
            DrawShaderProperty("_DirtAmount", "Dirt");
            DrawShaderProperty("_WearAmount", "Wear");
            DrawShaderProperty("_ScratchesAmount", "Scratches");
        }
    }
}
