using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// UIVFX 视觉效果着色器编辑GUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class UiVFXEditorShaderGUI : GeneralEditorShaderGUI
    {
        protected override void DrawHelpDesc(string desc = "", int h = 150)
        {
            base.DrawHelpDesc(
                "<color=#ffaaaaff>注意事项</color>\n\n" +
                "1. 由于着色器中包含外描边等需要外扩顶点及UV区域的视觉效果，因此需要配合同名文件<color=#fff999ff>（UiVFX.cs）</color>组件来使用；\n\n" +
                "2. 由于 Volume 原因，Scene 窗体与 Game 窗体下的渲染效果可能存在不同，渲染列表中的效果应以 Game 视窗下为准；\n"
                , h);
        }


        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_SplitBar0", "<color=#e7b4ffff>渲染项</color>" },
            new List<string>(){ "_SplitBar1", "<color=#e7b4ffff>着色列表</color>" },
            new List<string>(){ "_SplitBar2", "<color=#e7b4ffff>其他项</color>" },
            new List<string>(){ "_OutEdgeClr", "开启时，需要绑定 UiVFX.cs 组件." },
            new List<string>(){ "_ShadowAlphaThreshold", "开启时，需要绑定 UiVFX.cs 组件." },
        };


        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.FurtherSelect(materialEditor, properties);

            MaterialData data;
            List<string> lst;
            for (int i = 0; i < m_helpdesc.Count; i++)
            {
                lst = m_helpdesc[i];
                data = InMaterialDataList(lst[0]);
                if (data != null)
                    data.m_helpdesc = lst[1];
            }
        }
    }
}