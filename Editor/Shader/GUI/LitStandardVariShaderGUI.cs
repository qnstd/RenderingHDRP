namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��׼���ձ�����ɫ���������
    /// <para>���ߣ�ǿ��</para>
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