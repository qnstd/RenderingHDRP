using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ˫Ť����ɫ��ShaderGUI�༭���
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class TwistDoubleEditorShaderGUI : TwistBaseShaderGUI
    {
        public TwistDoubleEditorShaderGUI() : base(new List<List<string>>()
        {
            new List<string>(){ "_TwistUVParams", "xy��UV offset for first sample��\nzw��UV offset for second sample��" }
        })
        { }

    }

}