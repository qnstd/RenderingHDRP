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
                "Params��\n"+
                "x: Twist tex1 offset force of sample uv\n" +
                "y: Twist tex2 offset force of sample uv\n" +
                "z: The offset coefficient (density) multiplied by the addition of the two sampling results of the twist tex1\n" +
                "w: The offset coefficient (density) multiplied by the addition of the two sampling results of the twist tex2\n\n" +
                "Texture��\n" +
                "R: Vertical twist\n" +
                "G: Horizontal twist\n" +
                "BA: Unused"
            },
            new List<string>()
            {
                "_MainTex",
                "R: Shape (usually straight line)\n" +
                "G: Linear gradient\n" +
                "B: Alpha"
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