using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ����ͨ����ɫ�� ShaderGUI Inspector �༭��������ģ�ͣ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class ParticleStandardToModelEditorShaderGUI : GeneralEditorShaderGUI
    {
        #region �������
        //��������
        enum PropEnum
        {
            TEX,
            FLOAT
        }
        static List<List<object>> m_ShaderPropConf = new List<List<object>>()
        {
            new List<object>(){ "_MaskTex", "", PropEnum.TEX, null },
            new List<object>(){ "_DissolveTex", "", PropEnum.TEX, null },
            new List<object>(){ "_TwistTex", "", PropEnum.TEX, null },
            new List<object>(){ "_VertexAniTex", "", PropEnum.TEX, null },
            new List<object>(){ "_FresnelIntensity", "", PropEnum.FLOAT, 0 },
            new List<object>(){ "_Soft", "", PropEnum.FLOAT, 0.01f },
            new List<object>(){ "_Brightness,_Saturation,_Contrast", "_Hue", PropEnum.FLOAT, 1 },
        };

        static bool Compare(Material mat, string name, PropEnum type, object compare)
        {
            if (type == PropEnum.TEX)
            {
                return mat.GetTexture(name) != null;
            }
            else if (type == PropEnum.FLOAT)
            {
                float c = float.Parse(compare.ToString());
                if (name.IndexOf(",") == -1)
                    return mat.GetFloat(name) != c;
                else
                {
                    string[] vals = name.Split(",");
                    bool b = mat.GetFloat(vals[0]) != c;
                    for (int i = 1; i < vals.Length; i++)
                    {
                        b = b || (mat.GetFloat(vals[i]) != c);
                    }
                    return b;
                }
            }
            else { return false; }
        }

        static string GetKeyword(string propname, string variname)
        {
            string vari = string.IsNullOrEmpty(variname) ? propname : variname;
            return vari + "_On";
        }
        #endregion


        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.OnGUI(materialEditor, properties);

            #region ���Ʊ���
            Material mat = materialEditor.target as Material;
            List<object> lst;
            for(int i=0; i<m_ShaderPropConf.Count; i++)
            {
                lst = m_ShaderPropConf[i];
                string keyword = GetKeyword(lst[0].ToString(), lst[1].ToString());
                if (Compare(mat, lst[0].ToString(), (PropEnum)lst[2], lst[3])) { mat.EnableKeyword(keyword); }
                else { mat.DisableKeyword(keyword); }
            }
            #endregion
        }


        protected override void DrawHelpDesc(string desc = "", int h = 150)
        {
            base.DrawHelpDesc(desc, h);
        }


        //����˵����
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
            new List<string>(){ "_LuminancePow", "����ϵ������ȡ�����������ͼ��������ֵ��ϵ����ˡ��������С��1������ֵ˥�����෴������ֵ������˥���������Է����Գ��֣�\n����ָ����Ӱ����������˥���������ķ��ȣ�\n\n(�˲���������������ͼ��������ɫ�Ĳ��컯���ʸУ����ڿƼ������Ⱦ�����������)" },
            new List<string>(){ "_UVFloatParams", "xy: ����Ť�������UV�����ٶȣ�zw: ����Ť�����������UV�����ٶȡ�" },
            new List<string>(){ "_FresnelType", "Gradient: ��Ե�⽥�䡣ָ��ԽС��Ӱ������Խ��\nGeneral : ��Ե��ʵ�ġ�ָ��ԽС��Ӱ������ԽС��" },
        };

        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material mat = materialEditor.target as Material;

            string propname = "_LumFlag";
            MaterialData data = InMaterialDataList(propname);
            if (data != null)
            {
                bool b = (mat.GetFloat(propname) == 0) ? true : false;
                data = InMaterialDataList("_LumMulti");
                data.m_disabled = b;
                data.m_childIndentLv = true;
                data = InMaterialDataList("_LuminancePow");
                data.m_disabled = b;
                data.m_childIndentLv = true;
            }

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