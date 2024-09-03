using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 热扭曲材质ShaderGUI编辑面板（支持顶点变换的热扭曲）
    /// <para>作者：强辰</para>
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