using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 双扭曲着色器ShaderGUI编辑面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class TwistDoubleEditorShaderGUI : TwistBaseShaderGUI
    {
        public TwistDoubleEditorShaderGUI() : base(new List<List<string>>()
        {
            new List<string>(){ "_TwistUVParams", "xy：UV offset for first sample；\nzw：UV offset for second sample；" }
        })
        { }

    }

}