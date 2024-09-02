namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 薄膜干涉 + Cover覆盖色着色器的ShaderGUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class LitIridescenceCoverShaderGUI : LitStandardCoverShaderGUI
    {
        private IriShaderGUI irigui = new IriShaderGUI();

        protected override void ExtensionProps()
        {
            base.ExtensionProps();

            Gui.Space(10);
            irigui.Draw(m_Editor, m_Props);
        }
    }
}