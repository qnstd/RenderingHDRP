using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 表面细节混合着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class DetailHybridShaderGUI : ShaderGraphGUI
    {
        protected override void ExtensionProps()
        {
            DrawShaderProperty("_SAMPLESPACE", "Sample Space");

            Gui.Space(5);
            m_Editor.TexturePropertySingleLine(new GUIContent("Normal"), FindProp("_NormalDecal"));
            m_Editor.TexturePropertySingleLine(new GUIContent("Dirt"), FindProp("_DirtRTintGSmoothnessA"));
            Gui.Help("R: Dirt\nG: Hybrid Color\nA: Smooth Mask", MessageType.None);
            m_Editor.TexturePropertySingleLine(new GUIContent("Detail Mask"), FindProp("_DetailMaskRAOA"));
            Gui.Help("R: Mask\nA: AO", MessageType.None);

            Gui.Space(5);
            DrawShaderProperty("_MainColor", "Main Color");
            DrawShaderProperty("_TintColor", "Tint Color");
            DrawShaderProperty("_DetailColor", "Detail Color");

            Gui.Space(5);
            DrawShaderProperty("_Metallness", "Metallic");
            DrawShaderProperty("_DetailMetallness", "Detail Metallic");
            DrawShaderProperty("_Smoothness", "Smoothness");
            DrawShaderProperty("_DetailSmoothness", "Detail Smoothness");
            DrawShaderProperty("_DirtStrength", "Dirt Force");
            DrawShaderProperty("_DirtTile", "Dirt Tile");
            DrawShaderProperty("_DirBlendWeight", "Dirt BlendWeight");
        }
    }
}