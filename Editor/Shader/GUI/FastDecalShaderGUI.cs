using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ����������ɫ�����Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class FastDecalShaderGUI : ShaderGraphGUI
    {
        protected override void ExtensionProps()
        {
            DrawShaderProperty("_TEXWRAPMODE", "Tex Wrap Mode");
            Gui.Space(2);
            m_Editor.TexturePropertyWithHDRColor(new GUIContent("Tex"), FindProp("_Tex"), FindProp("_Color"), true);
            Gui.Space(2);
            DrawShaderProperty("_BrightnessVal", "Brightness");
            DrawShaderProperty("_ProjDistance", "Projector Distance");
        }
    }


}