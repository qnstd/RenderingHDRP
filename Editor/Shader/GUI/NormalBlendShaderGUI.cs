namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 表面法线融合着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class NormalBlendShaderGUI : ShaderGraphGUI
    {
        bool m_baseFoldout = true;
        bool m_dirtFoldout = true;
        bool m_detailFoldout = true;
        bool m_coatFoldout = true;


        protected override void ExtensionProps()
        {
            FoldoutGroup(ref m_baseFoldout, "Base", () =>
            {
                DrawShaderProperty("_BaseNormal", "Normal");
                DrawShaderProperty("_BaseNormalStrength", "Force");
                DrawShaderProperty("_BaseColor", "Color");
                DrawShaderProperty("_BaseColorOverlay", "Color Overlay");
                DrawShaderProperty("_BaseMetallic", "Metallic");
                DrawShaderProperty("_BaseSmoothness", "Smoothness");
            });


            FoldoutGroup(ref m_dirtFoldout, "Dirt", () =>
            {
                DrawShaderProperty("_DirtRoughness", "Tex");
                Gui.Help("R：The mixing difference factor between the base color and the base overlay color\nG：Intensity factor of dirt color\nB：Unused\nA：Smooth", UnityEditor.MessageType.None);
                DrawShaderProperty("_BaseDirtColor", "Color");
                DrawShaderProperty("_BaseDirtStrength", "Force");
            });


            FoldoutGroup(ref m_detailFoldout, "Detail", () =>
            {
                DrawShaderProperty("_DetailMask", "Tex");
                Gui.Help("R:Metallic \nG: AO\nB: Difference factor between base blend color and detail color blend (mask)\nA: Unused", UnityEditor.MessageType.None);
                DrawShaderProperty("_DetailColor", "Color");
                DrawShaderProperty("_DetailNormal", "Normal");
                DrawShaderProperty("_DetailEdgeWear", "Edge Wear");
                DrawShaderProperty("_DetailEdgeSmoothness", "Edge Smoothness");
                DrawShaderProperty("_DetailDirtStrength", "Dirt Force");
                DrawShaderProperty("_DetailOcclusionStrength", "Occlusion Force");
            });


            FoldoutGroup(ref m_coatFoldout, "Coat", () =>
            {
                DrawShaderProperty("_CoatTex", "Tex");
                DrawShaderProperty("_Cot", "Mask");
            });
        }


    }
}