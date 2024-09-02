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
            Gui.Label("表面");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            m_Editor.TexturePropertySingleLine(new UnityEngine.GUIContent("纹理（R：外层细节，G：内层细节，B：外层细节的扭曲噪声）"), FindProperty(ShaderPropIDs.ID_MixedTex, m_Props));
            DrawShaderProperty("_SurfaceRTile", "纹理R通道分布");
            DrawShaderProperty("_SurfaceGTile", "纹理G通道分布");
            DrawShaderProperty("_SurfaceSamplePow", "纹理采样指数");
            DrawShaderProperty("_RFloatSpeed", "R通道流动速度");
            DrawShaderProperty(ShaderPropIDs.ID_TwistUVTile, "扭曲纹理分布");
            DrawShaderProperty(ShaderPropIDs.ID_TwistSpeed, "扭曲速度");
            DrawShaderProperty(ShaderPropIDs.ID_TwistForce, "扭曲强度");
            DrawShaderProperty("_BottomColor", "外层颜色");
            DrawShaderProperty("_TopColor", "内层颜色");
            Gui.Space(3);
            Gui.IndentLevelSub();


            Gui.Space(5);
            fresnelGUI.Draw(m_Editor, m_Props);


            Gui.Space(5);
            Gui.Label("网格");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawShaderProperty("_VertexFresnelPow", "顶点摆动指数");
            DrawShaderProperty(ShaderPropIDs.ID_Amplitude, "振幅");
            DrawShaderProperty("_Speed", "动画速度");
            DrawShaderProperty("_Tile", "分布");
            Gui.Space(3);
            Gui.IndentLevelSub();
        }
    }

}