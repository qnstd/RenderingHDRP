using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 快速贴花着色器检视板
    /// <para>作者：强辰</para>
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