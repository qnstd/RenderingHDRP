using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 护盾着色器GUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class ShieldEditorShaderGUI : GeneralEditorShaderGUI
    {
        protected override void DrawHelpDesc(string desc = "", int h = 150)
        {
            base.DrawHelpDesc(
                "<color=#ffcc42ff>【特殊说明】</color>\n" +
                "   护盾着色器包含非交互及可交互功能。默认情况下，只需要创建材质并使用此着色器即可制作非交互的着色效果。\n" +
                "若要开启可交互功能，需要在材质所绑定的游戏对象上，挂载与着色器同名的<color=#ffcc42ff> c# </color>脚本文件。"
                , h);
        }


        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_TouchColorRadiasAtten", "交互参数执行的必要条件是，必须在游戏对象内绑定与着色器同名的可交互组件。" },

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