namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 薄膜干涉光照着色器GUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class LitStandardIridescenceShaderGUI : LitStanardVariShaderGUI
    {
        private IridescenceShaderGUI gui = new IridescenceShaderGUI();

        protected override void ExtensionProps()
        {
            base.ExtensionProps();
            Gui.Space(10);
            gui.Draw(m_Editor, m_Props);
        }

    }
}