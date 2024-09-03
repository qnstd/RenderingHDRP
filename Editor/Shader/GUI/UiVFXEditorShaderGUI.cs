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
        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_SplitBar0", "<color=#e7b4ffff>Rendering</color>" },
            new List<string>(){ "_SplitBar1", "<color=#e7b4ffff>Shader List</color>" },
            new List<string>(){ "_SplitBar2", "<color=#e7b4ffff>Others</color>" },
            new List<string>(){ "_OutEdgeClr", "Need to bind the UiVFX.cs component." },
            new List<string>(){ "_ShadowAlphaThreshold", "Need to bind the UiVFX.cs component." },
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