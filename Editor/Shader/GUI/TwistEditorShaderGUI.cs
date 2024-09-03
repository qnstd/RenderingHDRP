using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 热扭曲材质ShaderGUI编辑面板
    /// <para>作者：强辰</para>
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