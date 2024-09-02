using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��Ч����ͨ����ɫ�� ShaderGUI Inspector �༭��
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class ParticleStandardEditorShaderGUI : GeneralEditorShaderGUI
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
            base.DrawHelpDesc(
                "ע������:\n\n" +
                "   ParticleSystem �Զ�������˵��\n\n" +
                "       CustomData1\n" +
                "          <color=#e85b79ff>����ʱδʹ�á�</color>\n" +
                "\n" +
                "       CustomData2\n" +
                "           x   : �����Զ���<color=#9cf06eff>�ܽ�ϵ��</color>\n" +
                "           y   : �����Զ���<color=#9cf06eff>Ť��ǿ��</color>\n" +
                "\n" +
                "       <color=#f6dc82ff>*** customData1��customData2 ������ϵͳ������ɫ���ṩ�Զ������ݡ����������ݱ�����ڣ���˳���ܴ�\n" +
                "       *** customData1 �ı�Ǳ����� TEXCOORD0��customData2 �ı�Ǳ����� TEXCOORD1���� customData1 �� customData2 ���������ͱ����� Vector��ͬʱ Vector ����ӦΪ 2��\n" +
                "       *** �������� Vector ��Ϊ�˼��� DOTs ECS ��ʹ�� CustomPassDrawRenderer �����Ⱦ���ײ�����������float2�� ʹ�õ��� xy��zw�����ԡ�������ϵͳ���Զ���������ֻʹ�� xy ���ͣ���ô TEXCOORD �Ĵ���������������зָ���ǲ���ʽ�����Ӱ��ײ��ȡ���ݵ�׼ȷ�ԡ�</color>\n" +
                "\n" +
                "       Ϊ�˱�֤����ϵͳ�� ParticleStandard ���ʶ����Զ������ݴ���Ŀɿ��ԣ�Graphi ��ɫ���ṩ��ֱ�Ӵ��� ParticleSystem ��Ϸ���󹤾ߣ��Զ�Ϊʹ�� ParticleStandard ���ʵ���Ч�����Ҫ������\n" +
                "       �� Hierarchy �б�������Ҽ���ѡ��<color=#f6dc82ff> ��Graphi��->�����ӡ�->����������ͨ�ò��ʵ�����ϵͳ����</color>���ɡ�" +
                "\n"
                , 235);
        }


        //����˵����
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: �����ֶΣ�1: ������صİ���˵��
            new List<string>(){ "_LuminancePow", "����ϵ������ȡ�����������ͼ��������ֵ��ϵ����ˡ��������С��1������ֵ˥�����෴������ֵ������˥���������Է����Գ��֣�\n����ָ����Ӱ����������˥���������ķ��ȣ�\n\n(�˲���������������ͼ��������ɫ�Ĳ��컯���ʸУ����ڿƼ������Ⱦ�����������)" },
            new List<string>(){ "_UVFloatParams", "xy: ����Ť�������UV�����ٶȣ�zw: ����Ť�����������UV�����ٶȡ�" },
            new List<string>(){ "_FresnelType", "Gradient: ��Ե�⽥�䡣ָ��ԽС��Ӱ������Խ��\nGeneral : ��Ե��ʵ�ġ�ָ��ԽС��Ӱ������ԽС��" },
            new List<string>(){ "_DissolveIntensityType", "������Դ��Ϊ Custom ���ͣ����ȡ����ϵͳ�� CustomData2 ����԰�е� x ��ֵ��ͬʱ���ܽ�̶ȿؼ��޷�������" },
            new List<string>(){ "_TwistIntensityType", "������Դ��Ϊ Custom ���ͣ����ȡ����ϵͳ�� CustomData2 ����԰�е� y ��ֵ��ͬʱ��Ť���̶ȿؼ��޷�������" },
        };

        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material mat = materialEditor.target as Material;

            string propname = "_DissolveIntensityType";
            MaterialData data = InMaterialDataList(propname);
            if (data != null)
            {
                data = InMaterialDataList("_DissolveIntensity");
                if(data != null)
                    data.m_disabled = (mat.GetFloat(propname) == 0) ? true : false;
            }

            
            propname = "_TwistIntensityType";
            data = InMaterialDataList(propname);
            if(data != null)
            {
                data = InMaterialDataList("_TwistIntensity");
                if(data != null)
                    data.m_disabled = (mat.GetFloat(propname) == 0) ? true : false;
            }

            propname = "_LumFlag";
            data = InMaterialDataList(propname);
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