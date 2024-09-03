using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// UIVFX �Ӿ�Ч����ɫ���༭GUI
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class UiVFXEditorShaderGUI : GeneralEditorShaderGUI
    {
        //����˵����
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
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