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
        protected override void DrawHelpDesc(string desc = "", int h = 150)
        {
            base.DrawHelpDesc(
                "<color=#ffaaaaff>ע������</color>\n\n" +
                "1. ������ɫ���а�������ߵ���Ҫ�������㼰UV������Ӿ�Ч���������Ҫ���ͬ���ļ�<color=#fff999ff>��UiVFX.cs��</color>�����ʹ�ã�\n\n" +
                "2. ���� Volume ԭ��Scene ������ Game �����µ���ȾЧ�����ܴ��ڲ�ͬ����Ⱦ�б��е�Ч��Ӧ�� Game �Ӵ���Ϊ׼��\n"
                , h);
        }


        //����˵����
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
            new List<string>(){ "_SplitBar0", "<color=#e7b4ffff>��Ⱦ��</color>" },
            new List<string>(){ "_SplitBar1", "<color=#e7b4ffff>��ɫ�б�</color>" },
            new List<string>(){ "_SplitBar2", "<color=#e7b4ffff>������</color>" },
            new List<string>(){ "_OutEdgeClr", "����ʱ����Ҫ�� UiVFX.cs ���." },
            new List<string>(){ "_ShadowAlphaThreshold", "����ʱ����Ҫ�� UiVFX.cs ���." },
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