
using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ������Χ�����ᡢ�籩��ɫ���� ShaderGUI 
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class SunCoronaShaderGUI : GeneralEditorShaderGUI
    {
        //����˵����
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
            new List<string>(){ "_HybridMap", "R���籩\nG: ���ᣨͬʱ���ڷ籩�Ļ�����ӣ�\nBA������δʹ�á�" },
            
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

