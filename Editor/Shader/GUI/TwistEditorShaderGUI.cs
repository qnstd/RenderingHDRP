using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��Ť������ShaderGUI�༭���
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class TwistEditorShaderGUI : TwistBaseShaderGUI
    {
        public TwistEditorShaderGUI() : base(new List<List<string>>()
        {
            new List<string>(){ "_UVParams", "xy: Noise tex UV speed \nzw: Mask tex UV speed" },
        })
        { }

    }
}