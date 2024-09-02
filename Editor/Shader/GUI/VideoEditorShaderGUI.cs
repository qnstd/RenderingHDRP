using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// Video��Ƶ��ɫ���ļ������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class VideoEditorShaderGUI : GeneralEditorShaderGUI
    {
        // ��ǰ�˾�����
        int curFilterType = 0;
        // ���� shader �е��˾�����˳��Ϊ���������Կ��Ʋ��������ͽ���ע�ᡣע�������Ǵ��� Foldout ��ǵ���������
        string[] funcs = new string[] { "", "", "", "_Relief", "_Mosaic" };
        // ����
        string[] varis = new string[] { "", "_BlackWhite", "_OldPhotos", "_Relief", "_Mosaic" };



        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material mat = materialEditor.target as Material;
            int type = mat.GetInt("_FilterType");
            if (curFilterType != type)
            {
                curFilterType = type;
            }


            for (int i = 0; i < funcs.Length; i++)
            {
                // ���Ʊ���
                string variname = $"{varis[i]}_On";
                if (variname != "_On")
                {
                    if (curFilterType != 0 && i == curFilterType)
                        mat.EnableKeyword(variname);
                    else
                        mat.DisableKeyword(variname);
                }


                // ��������е���ʾ��ر�
                MaterialData data = InMaterialDataList(funcs[i]);
                if (data == null) { continue; }
                data.m_disabled = (i == curFilterType) ? false : true;
                mat.SetInt(funcs[i], (i == curFilterType) ? 1 : 0);
            }


            MaterialData data0;
            List<string> lst;
            for (int i = 0; i < m_helpdesc.Count; i++)
            {
                lst = m_helpdesc[i];
                data0 = InMaterialDataList(lst[0]);
                if (data0 != null)
                    data0.m_helpdesc = lst[1];
            }
        }


        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
            new List<string>(){ "_SplitBar0", "<color=#e7b4ffff>�������б�</color>" },
        };


    }
}