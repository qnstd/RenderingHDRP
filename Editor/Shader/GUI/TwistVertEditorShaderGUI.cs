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
            new List<string>(){ "_UVParams", "xy: 扭曲纹理的 UV 流动速度 \nzw: 顶点偏移纹理的 UV 流动速度" },

        }) { }

    }
}