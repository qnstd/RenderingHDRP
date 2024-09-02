using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ������Ч��ɫ�����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class FogEditorShaderGUI : GeneralEditorShaderGUI
    {
        //����˵����
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
            new List<string>(){ "_DesaturatePower", "����������ɫ����Ĭ����ɫʱ���Ҷȴ���ֻ�������������������ء�" },
            new List<string>(){ "_RadialIntensity", "�������ֵ�ģ����PhotoShop�ľ��򽥱�һ�£����ڵ���ִ�н������֡�ǿ��ֵ��0���ٽ�㣬�����⵽��ִ�н������ֲü������ٽ��ֵ֮��ִ�н�����ʧ��������ǽ������ŵĹ��̡�" },
            new List<string>(){ "_Far", "�����������û�ָ��Զ��������䵱�������Զ�����ü�����ʵ��ǿ����ϵ����ʹ�õ�ǰ�����Զ�����ü����ǿ��ǵ�Զ�ü������ʱ���ᵼ������ʧ��" },
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

