namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 绒毛着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class FurShaderGUI : LitStanardVariShaderGUI
    {
        private bool m_FurFlag = true;

        public FurShaderGUI()
        {
            uiBlocks.RemoveRange(0, 2);
        }

        protected override void ExtensionProps()
        {
            base.ExtensionProps();

            Gui.Space(10);

            FoldoutGroup(ref m_FurFlag, "Fur", () =>
            {
                DrawTex("Noise", "_FurMap");
                DrawTex("Noise Normal", "_FurNormalMap");
                DrawShaderProperty("_FurNormalForce", "Normal Force");
                DrawIntRange("Layer", "_Length");
                DrawShaderProperty("_Step", "Step");
                DrawShaderProperty("_Density", "Density");
                DrawShaderProperty("_Cutoffs", "Alpha Threshold");
                DrawShaderProperty("_Occlusion", "AO");
                DrawShaderProperty("_BaseOffset", "Base Offset");
                DrawShaderProperty("_WindOffset", "Wind Offset");
                DrawShaderProperty("_WindAxisWeight", "Wind Axis Weight");
                DrawShaderProperty("_WindForce", "Wind Force");
                DrawShaderProperty("_WindDisturbance", "Wind Disturbance");

            });

        }
    }
}