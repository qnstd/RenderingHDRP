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


        protected override void DrawHelpDesc(string desc = "", int h = 150)
        {
            base.DrawHelpDesc(
                "<color=#f69999ff>ע������:</color>\n\n" +
                "1. Ҫ����ȷ��Ⱦ��Ť��Ч�������봴���ض�����Ť����Ⱦ������������ Hierarchy �б�����Ҽ��ֶ���ӣ�ѡ��<color=#f6dc82ff>��Graphi��->����Ⱦͨ����->����Ť����</color>��\n�ڴ������������У���������Զ�������ϣ������ֶ����á�������ʱ����Ⱦ����Զ�������Ť����Ⱦ�����������䵽ÿ��������<color=#f6dc82ff>�������л򳡾����з����鿴��Ť����ȾЧ��������ɾ��������ã���ǰ�����ֶ���������Ť����Ⱦ������</color>��\n\n" +
                "2. �������ض�����Ⱦͨ������Ⱦ��Ť��Ч�������<color=#f6dc82ff>�������󶨵���Ϸ����� Layer �㼶�����ǹ涨�Ĳ㼶</color>���㼶�ڴ�����Ⱦ����ʱ���Զ������ϣ��㼶��������Ⱦͨ�������Ƽ� LayerMask һ�£�\n\n" +
                "3. �� Scene �����£�Unity ֻ�����˵���������л��ƣ������Ť����Ȼ�����õ������㼶������Ⱦ������ Scene ģʽ�»�� Default ��һ����Ⱦ��Ҳ���Ƕ������һ�Ρ������ϻ�����ɫ���ӵĿ��ܡ����ʵ��Ч���� Game ��������ʾ��Ϊ׼��\n", h);
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