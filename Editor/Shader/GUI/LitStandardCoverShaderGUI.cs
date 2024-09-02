namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 带有覆盖色的标准光照着色器材质面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class LitStandardCoverShaderGUI : LitStanardVariShaderGUI
    {
        private CoverShaderGUI gui = new CoverShaderGUI();

        protected override void ExtensionProps()
        {
            base.ExtensionProps();

            Gui.Space(20);
            gui.Draw(m_Editor, m_Props);
        }
    }
}