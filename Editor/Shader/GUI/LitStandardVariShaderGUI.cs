namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 标准光照变体着色器材质面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class LitStanardVariShaderGUI : ShaderGraphGUI
    {
        private LitStandardShaderGUI gui;


        public LitStanardVariShaderGUI()
        {
            gui = new LitStandardShaderGUI();
        }

        protected override void ExtensionProps()
        {
            gui.Draw(m_Editor, m_Props);
        }
    }
}