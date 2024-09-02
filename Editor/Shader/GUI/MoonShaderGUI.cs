using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 月球着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class MoonShaderGUI : ShaderGraphGUI
    {

        TriSampleShaderGUI normalTriGUI = new TriSampleShaderGUI(TriSampleShaderGUI.TriSampleType.Normal, "法线");


        protected override void ExtensionProps()
        {
            Gui.Label("反照率 & 细节");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertySingleLine
                (
                    new GUIContent("纹理（R：反照率，G：细节）"),
                    FindProperty(ShaderPropIDs.ID_AlbedoTex, m_Props)
                );
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoColor, "反照率颜色");
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoUVTile, "反照率UV瓦片");
            DrawShaderProperty(ShaderPropIDs.ID_DetailColor, "细节颜色");
            DrawShaderProperty(ShaderPropIDs.ID_DetailUVTile, "细节UV瓦片");
            DrawShaderProperty(ShaderPropIDs.ID_DetailPow, "细节指数");
            DrawShaderProperty(ShaderPropIDs.ID_DetailForce, "细节强度");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            normalTriGUI.Draw(m_Editor, m_Props);


            Gui.Space(5);
            DrawShaderProperty(ShaderPropIDs.ID_Metallic, "金属度");
            DrawShaderProperty(ShaderPropIDs.ID_Smooth, "平滑度");
        }

    }
}