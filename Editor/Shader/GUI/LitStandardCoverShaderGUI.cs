namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ���и���ɫ�ı�׼������ɫ���������
    /// <para>���ߣ�ǿ��</para>
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