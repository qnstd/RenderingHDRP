using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 月球着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class MoonShaderGUI : ShaderGraphGUI
    {

        TriSampleShaderGUI normalTriGUI = new TriSampleShaderGUI(TriSampleShaderGUI.TriSampleType.Normal, "Normal");


        protected override void ExtensionProps()
        {
            Gui.Label("Albedo & Detail");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertyWithHDRColor(new GUIContent("Tex"), FindProp(ShaderPropIDs.ID_AlbedoTex), FindProp(ShaderPropIDs.ID_AlbedoColor), true);
            Gui.Help("R：Albedo\nG：Detail", UnityEditor.MessageType.None);
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoUVTile, "UV Tile");
            DrawShaderProperty(ShaderPropIDs.ID_DetailColor, "Detail Color");
            DrawShaderProperty(ShaderPropIDs.ID_DetailUVTile, "Detail UV Tile");
            DrawShaderProperty(ShaderPropIDs.ID_DetailPow, "Detail Pow");
            DrawShaderProperty(ShaderPropIDs.ID_DetailForce, "Detail Force");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            normalTriGUI.Draw(m_Editor, m_Props);


            Gui.Space(5);
            DrawShaderProperty(ShaderPropIDs.ID_Metallic, "Metallic");
            DrawShaderProperty(ShaderPropIDs.ID_Smooth, "Smoothing");
        }

    }
}