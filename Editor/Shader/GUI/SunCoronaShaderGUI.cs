
using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 星体周围的日冕、风暴着色器的 ShaderGUI 
    /// <para>作者：强辰</para>
    /// </summary>
    public class SunCoronaShaderGUI : GeneralEditorShaderGUI
    {
        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_HybridMap", "R：风暴\nG: 日冕（同时用于风暴的混合因子）\nBA：【暂未使用】" },
            
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

