namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��Ĥ���������ɫ��GUI
    /// <para>���ߣ�ǿ��</para>
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