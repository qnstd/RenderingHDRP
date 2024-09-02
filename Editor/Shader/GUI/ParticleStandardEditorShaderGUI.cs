using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 特效粒子通用着色器 ShaderGUI Inspector 编辑器
    /// <para>作者：强辰</para>
    /// </summary>
    public class ParticleStandardEditorShaderGUI : GeneralEditorShaderGUI
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
            base.DrawHelpDesc(
                "注意事项:\n\n" +
                "   ParticleSystem 自定义数据说明\n\n" +
                "       CustomData1\n" +
                "          <color=#e85b79ff>【暂时未使用】</color>\n" +
                "\n" +
                "       CustomData2\n" +
                "           x   : 负责自定义<color=#9cf06eff>溶解系数</color>\n" +
                "           y   : 负责自定义<color=#9cf06eff>扭曲强度</color>\n" +
                "\n" +
                "       <color=#f6dc82ff>*** customData1、customData2 在粒子系统中向着色器提供自定义数据。这两个数据必须存在，且顺序不能错。\n" +
                "       *** customData1 的标记必须是 TEXCOORD0，customData2 的标记必须是 TEXCOORD1，且 customData1 和 customData2 的数据类型必须是 Vector，同时 Vector 长度应为 2。\n" +
                "       *** 数据类型 Vector 是为了兼容 DOTs ECS 下使用 CustomPassDrawRenderer 框架渲染。底层数据类型是float2， 使用的是 xy，zw被忽略。若粒子系统的自定义数据若只使用 xy 类型，那么 TEXCOORD 寄存器不是以整体进行分割，而是插入式。这会影响底层获取数据的准确性。</color>\n" +
                "\n" +
                "       为了保证粒子系统与 ParticleStandard 材质对于自定义数据传输的可靠性，Graphi 着色库提供了直接创建 ParticleSystem 游戏对象工具，自动为使用 ParticleStandard 材质的特效适配必要参数。\n" +
                "       在 Hierarchy 列表中鼠标右键，选择<color=#f6dc82ff> 【Graphi】->【粒子】->【创建兼容通用材质的粒子系统对象】</color>即可。" +
                "\n"
                , 235);
        }


        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_LuminancePow", "亮度系数：提取主纹理的亮度图，将亮度值与系数相乘。操作结果小于1，亮度值衰减。相反，亮度值递增。衰减、递增以非线性呈现；\n亮度指数：影响最终亮度衰减、递增的幅度；\n\n(此操作可以增加主贴图采样后颜色的差异化及质感，对于科技类的渲染需求很有作用)" },
            new List<string>(){ "_UVFloatParams", "xy: 负责扭曲纹理的UV流动速度，zw: 负责扭曲遮罩纹理的UV流动速度。" },
            new List<string>(){ "_FresnelType", "Gradient: 边缘光渐变。指数越小，影响区域越大。\nGeneral : 边缘光实心。指数越小，影响区域越小。" },
            new List<string>(){ "_DissolveIntensityType", "数据来源若为 Custom 类型，则读取粒子系统的 CustomData2 数据园中的 x 数值。同时，溶解程度控件无法操作。" },
            new List<string>(){ "_TwistIntensityType", "数据来源若为 Custom 类型，则读取粒子系统的 CustomData2 数据园中的 y 数值。同时，扭曲程度控件无法操作。" },
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