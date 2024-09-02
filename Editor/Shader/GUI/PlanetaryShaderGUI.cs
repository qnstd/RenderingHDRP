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
            Gui.Label("表面");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("纹理"), FindProperty(ShaderPropIDs.ID_AlbedoTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_AlbedoColor, "");
            Gui.EndHor();
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("法线"), FindProperty(ShaderPropIDs.ID_NormalTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_NormalStrength, "");
            Gui.EndHor();
            DrawShaderProperty(ShaderPropIDs.ID_TriUVTile, "瓦片");
            DrawShaderProperty(ShaderPropIDs.ID_TriBlendWeight, "采样权重");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            Gui.Label("细节");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            Gui.Hor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("纹理（R：灰度、G：遮罩、B：平滑度）"), FindProperty(ShaderPropIDs.ID_DetailTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_DetailColor, "");
            Gui.EndHor();
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("法线"), FindProperty(ShaderPropIDs.ID_DetailNormalTex, m_Props));
            DrawShaderProperty(ShaderPropIDs.ID_DetailUVTile, "瓦片");
            DrawShaderProperty(ShaderPropIDs.ID_DetailBlendWeight, "采样权重");
            DrawShaderProperty(ShaderPropIDs.ID_DetailAlbedoScal, "纹理强度");
            DrawShaderProperty(ShaderPropIDs.ID_DetailNormalScal, "法线强度");
            DrawShaderProperty(ShaderPropIDs.ID_DetailSmoothnessScal, "平滑度强度");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            Gui.Label("PBR");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawShaderProperty(ShaderPropIDs.ID_Metallic, "金属度");
            DrawShaderProperty(ShaderPropIDs.ID_Smooth, "平滑度");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            fresnelGUI.Draw(m_Editor, m_Props);
        }
    }

}

