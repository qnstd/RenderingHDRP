using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 粒子通用着色器 ShaderGUI Inspector 编辑器（用于模型）
    /// <para>作者：强辰</para>
    /// </summary>
    public class ParticleStandardToModelEditorShaderGUI : GeneralEditorShaderGUI
    {
        #region 变体控制
        //变体配置
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

            #region 控制变体
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


        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_LuminancePow", "亮度系数：提取主纹理的亮度图，将亮度值与系数相乘。操作结果小于1，亮度值衰减。相反，亮度值递增。衰减、递增以非线性呈现；\n亮度指数：影响最终亮度衰减、递增的幅度；\n\n(此操作可以增加主贴图采样后颜色的差异化及质感，对于科技类的渲染需求很有作用)" },
            new List<string>(){ "_UVFloatParams", "xy: 负责扭曲纹理的UV流动速度，zw: 负责扭曲遮罩纹理的UV流动速度。" },
            new List<string>(){ "_FresnelType", "Gradient: 边缘光渐变。指数越小，影响区域越大。\nGeneral : 边缘光实心。指数越小，影响区域越小。" },
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