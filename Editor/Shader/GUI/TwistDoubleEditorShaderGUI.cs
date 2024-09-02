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
            new List<string>(){ "_TwistUVParams", "xy：第一次采样时的UV偏移设置；\nzw：第二次采样时的UV偏移设置；" },
            new List<string>(){ "_MskTex", "蒙版的作用是用于解决硬边儿（齐边儿）问题，使扭曲对象的边缘与背景间更加平滑。若扭曲对象的边缘处不会与任何对象产生前后深度关系，无需设置蒙版。" }
        }) { }

    }

}