namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 行星通用着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class PlanetaryShaderGUI : ShaderGraphGUI
    {
        FresnelLightShaderGUI fresnelGUI = new FresnelLightShaderGUI();


        protected override void ExtensionProps()
        {
            Gui.Label("Surface");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertyWithHDRColor(new UnityEngine.GUIContent("Tex"), FindProp(ShaderPropIDs.ID_AlbedoTex), FindProp(ShaderPropIDs.ID_AlbedoColor), true);
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("Normal"), FindProperty(ShaderPropIDs.ID_NormalTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_NormalStrength, "");
            Gui.EndHor();
            DrawShaderProperty(ShaderPropIDs.ID_TriUVTile, "Tile");
            DrawShaderProperty(ShaderPropIDs.ID_TriBlendWeight, "Blend Weight");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            Gui.Label("Detail");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertyWithHDRColor(new UnityEngine.GUIContent("Tex"), FindProp(ShaderPropIDs.ID_DetailTex), FindProp(ShaderPropIDs.ID_DetailColor), true);
            Gui.Help("R：Gray\nG：Mask\nB：Smooth", UnityEditor.MessageType.None);
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("Normal"), FindProperty(ShaderPropIDs.ID_DetailNormalTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_DetailUVTile, "Tile");
            DrawShaderProperty(ShaderPropIDs.ID_DetailBlendWeight, "Blend Weight");
            DrawShaderProperty(ShaderPropIDs.ID_DetailAlbedoScal, "Albedo Force");
            DrawShaderProperty(ShaderPropIDs.ID_DetailNormalScal, "Normal Force");
            DrawShaderProperty(ShaderPropIDs.ID_DetailSmoothnessScal, "Smooth Force");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            Gui.Label("PBR");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawShaderProperty(ShaderPropIDs.ID_Metallic, "Metallic");
            DrawShaderProperty(ShaderPropIDs.ID_Smooth, "Smoothing");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            fresnelGUI.Draw(m_Editor, m_Props);
        }
    }

}

