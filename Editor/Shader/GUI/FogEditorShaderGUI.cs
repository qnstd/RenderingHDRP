using System.Collections.Generic;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 场景雾效着色器面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class FogEditorShaderGUI : GeneralEditorShaderGUI
    {
        //帮助说明组
        List<List<string>> m_helpdesc = new List<List<string>>()
        {//0: 属性字段；1: 属性相关的帮助说明
            new List<string>(){ "_DesaturatePower", "当主纹理颜色不是默认颜色时，灰度处理只处理主纹理采样后的像素。" },
            new List<string>(){ "_RadialIntensity", "径向遮罩的模型与PhotoShop的径向渐变一致，由内到外执行渐变遮罩。强度值从0到临界点，是由外到内执行渐变遮罩裁剪，从临界点值之后执行渐变消失。整体就是渐变缩放的过程。" },
            new List<string>(){ "_Far", "当开启后，由用户指定远，近距离充当摄像机的远，近裁剪面来实现强弱关系。不使用当前相机的远、近裁剪面是考虑到远裁剪面过大时，会导致雾消失。" },
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

