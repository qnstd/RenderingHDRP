using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 闪电着色器 Inspector 操作面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class LightningShaderGUI : GeneralEditorShaderGUI
    {
        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>()
            { 
                "_TwistParams", 
                "参数说明：\n"+
                "x: 扭曲纹理1采样坐标的偏移强度；\n" +
                "y: 扭曲纹理2采样坐标的偏移程度；\n" +
                "z: 对扭曲纹理1两次采样结果相加后相乘的偏移系数（密度）；\n" +
                "w: 对扭曲纹理2两次采样结果相加后相乘的偏移系数（密度）；\n\n" +
                "纹理说明：\n" +
                "扭曲纹理图只需要R、G两个通道。其中：\n" +
                "R: 纵向扭曲值；\n" +
                "G: 横向扭曲值；" 
            },
            new List<string>()
            {
                "_MainTex",
                "R: 颜色。闪电形状（一般是直线）；\n" +
                "G: 线性渐变。用于做偏移，与_Offset变量做相加操作；\n" +
                "B: 透明度。用于裁剪，与顶点颜色Alpha值做减法，小于0则被裁剪掉；"
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