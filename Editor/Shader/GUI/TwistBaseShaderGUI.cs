using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ����Ť����ɫ����ShaderGUI����������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class TwistBaseShaderGUI : GeneralEditorShaderGUI
    {
        /// <summary>
        /// �ֶ�˵��������
        /// <para>�����Ƕ�ά���飬����Ԫ����List���͡�List�а�������������0: �����ֶΡ�1: ������صİ���˵��</para>
        /// </summary>
        protected List<List<string>> m_helpdesc = new List<List<string>>();


        public TwistBaseShaderGUI(List<List<string>> helpDesc = null)
        {
            if (helpDesc != null && helpDesc.Count != 0)
                m_helpdesc.AddRange(helpDesc);
        }



        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.FurtherSelect(materialEditor, properties);

            if (m_helpdesc.Count == 0) { return; }
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