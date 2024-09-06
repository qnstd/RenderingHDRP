namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 太阳着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class SunShaderGUI : ShaderGraphGUI
    {

        FresnelShaderGUI fresnelGUI = new FresnelShaderGUI();

        protected override void ExtensionProps()
        {
            Gui.Label("Surface");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("Tex"), FindProperty(ShaderPropIDs.ID_MixedTex, m_Props));
            Gui.Help("R：Out Detail\nG：Inner Detail\nB：Out Detail Twist Noise", UnityEditor.MessageType.None);
            DrawShaderProperty("_SurfaceSamplePow", "Sample Pow");
            DrawShaderProperty("_SurfaceGTile", "G channel Tile");
            DrawShaderProperty("_SurfaceRTile", "R channel Tile");
            DrawShaderProperty("_RFloatSpeed", "R Channel Speed");
            DrawShaderProperty(ShaderPropIDs.ID_TwistUVTile, "Twist UV Tile");
            DrawShaderProperty(ShaderPropIDs.ID_TwistSpeed, "Twist Speed");
            DrawShaderProperty(ShaderPropIDs.ID_TwistForce, "Twist Force");
            DrawShaderProperty("_BottomColor", "Out Color");
            DrawShaderProperty("_TopColor", "Inner Color");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            fresnelGUI.Draw(m_Editor, m_Props);


            Gui.Space(5);
            Gui.Label("Mesh");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawShaderProperty("_VertexFresnelPow", "Pow");
            DrawShaderProperty(ShaderPropIDs.ID_Amplitude, "Amp");
            DrawShaderProperty("_Speed", "Speed");
            DrawShaderProperty("_Tile", "Tile");
            Gui.Space(3);
            Gui.IndentLevelSub();
        }
    }

}