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
            new List<string>(){ "_TwistUVParams", "xy����һ�β���ʱ��UVƫ�����ã�\nzw���ڶ��β���ʱ��UVƫ�����ã�" },
            new List<string>(){ "_MskTex", "�ɰ�����������ڽ��Ӳ�߶�����߶������⣬ʹŤ������ı�Ե�뱳�������ƽ������Ť������ı�Ե���������κζ������ǰ����ȹ�ϵ�����������ɰ档" }
        }) { }

    }

}