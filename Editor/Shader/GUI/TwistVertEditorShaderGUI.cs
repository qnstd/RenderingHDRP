using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��Ť������ShaderGUI�༭��壨֧�ֶ���任����Ť����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class TwistVertEditorShaderGUI : TwistBaseShaderGUI
    {
        public TwistVertEditorShaderGUI() : base(new List<List<string>>()
        {
            new List<string>(){ "_UVParams", "xy: twist tex UV speed \nzw: vertex offset tex UV speed" },

        })
        { }

    }
}