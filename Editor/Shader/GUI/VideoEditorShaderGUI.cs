using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// Video视频着色器的检视面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class VideoEditorShaderGUI : GeneralEditorShaderGUI
    {
        // 当前滤镜类型
        int curFilterType = 0;
        // 按照 shader 中的滤镜类型顺序，为具有子属性控制参数的类型进行注册。注册名称是带有 Foldout 标记的属性名。
        string[] funcs = new string[] { "", "", "", "_Relief", "_Mosaic" };
        // 变体
        string[] varis = new string[] { "", "_BlackWhite", "_OldPhotos", "_Relief", "_Mosaic" };



        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material mat = materialEditor.target as Material;
            int type = mat.GetInt("_FilterType");
            if (curFilterType != type)
            {
                curFilterType = type;
            }


            for (int i = 0; i < funcs.Length; i++)
            {
                // 控制变体
                string variname = $"{varis[i]}_On";
                if (variname != "_On")
                {
                    if (curFilterType != 0 && i == curFilterType)
                        mat.EnableKeyword(variname);
                    else
                        mat.DisableKeyword(variname);
                }


                // 检视面板中的显示与关闭
                MaterialData data = InMaterialDataList(funcs[i]);
                if (data == null) { continue; }
                data.m_disabled = (i == curFilterType) ? false : true;
                mat.SetInt(funcs[i], (i == curFilterType) ? 1 : 0);
            }


            MaterialData data0;
            List<string> lst;
            for (int i = 0; i < m_helpdesc.Count; i++)
            {
                lst = m_helpdesc[i];
                data0 = InMaterialDataList(lst[0]);
                if (data0 != null)
                    data0.m_helpdesc = lst[1];
            }
        }


        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_SplitBar0", "<color=#e7b4ffff>子属性列表</color>" },
        };


    }
}