using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 关于扭曲着色器的ShaderGUI操作面板基类
    /// <para>作者：强辰</para>
    /// </summary>
    public class TwistBaseShaderGUI : GeneralEditorShaderGUI
    {
        /// <summary>
        /// 字段说明缓存组
        /// <para>变量是二维数组，其中元素是List类型。List中包含两个参数，0: 属性字段、1: 属性相关的帮助说明</para>
        /// </summary>
        protected List<List<string>> m_helpdesc = new List<List<string>>();


        public TwistBaseShaderGUI(List<List<string>> helpDesc = null)
        {
            if (helpDesc != null && helpDesc.Count != 0)
                m_helpdesc.AddRange(helpDesc);
        }



        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.FurtherSelect(materialEditor, properties);

            if (m_helpdesc.Count == 0) { return; }
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