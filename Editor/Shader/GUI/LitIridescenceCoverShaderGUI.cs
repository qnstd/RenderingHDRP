namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��Ĥ���� + Cover����ɫ��ɫ����ShaderGUI
    /// <para>���ߣ�ǿ��</para>
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