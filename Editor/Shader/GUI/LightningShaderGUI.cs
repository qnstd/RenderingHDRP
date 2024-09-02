using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ������ɫ�� Inspector �������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class LightningShaderGUI : GeneralEditorShaderGUI
    {
        //����˵����
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
            new List<string>()
            { 
                "_TwistParams", 
                "����˵����\n"+
                "x: Ť������1���������ƫ��ǿ�ȣ�\n" +
                "y: Ť������2���������ƫ�Ƴ̶ȣ�\n" +
                "z: ��Ť������1���β��������Ӻ���˵�ƫ��ϵ�����ܶȣ���\n" +
                "w: ��Ť������2���β��������Ӻ���˵�ƫ��ϵ�����ܶȣ���\n\n" +
                "����˵����\n" +
                "Ť������ͼֻ��ҪR��G����ͨ�������У�\n" +
                "R: ����Ť��ֵ��\n" +
                "G: ����Ť��ֵ��" 
            },
            new List<string>()
            {
                "_MainTex",
                "R: ��ɫ��������״��һ����ֱ�ߣ���\n" +
                "G: ���Խ��䡣������ƫ�ƣ���_Offset��������Ӳ�����\n" +
                "B: ͸���ȡ����ڲü����붥����ɫAlphaֵ��������С��0�򱻲ü�����"
            },
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