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


        protected override void DrawHelpDesc(string desc = "", int h = 150)
        {
            base.DrawHelpDesc(
                "<color=#f69999ff>注意事项:</color>\n\n" +
                "1. 要想正确渲染热扭曲效果，必须创建特定的热扭曲渲染驱动器；可在 Hierarchy 列表鼠标右键手动添加，选择<color=#f6dc82ff>【Graphi】->【渲染通道】->【热扭曲】</color>。\n在创建的驱动器中，其参数已自动设置完毕，无需手动设置。在运行时，渲染库会自动创建热扭曲渲染驱动器并适配到每个场景。<color=#f6dc82ff>若需运行或场景进行发布查看热扭曲渲染效果，必须删除（或禁用）当前场景手动创建的热扭曲渲染驱动器</color>；\n\n" +
                "2. 由于以特定的渲染通道来渲染热扭曲效果，因此<color=#f6dc82ff>材质所绑定的游戏对象的 Layer 层级必须是规定的层级</color>。层级在创建渲染驱动时已自动添加完毕，层级名称与渲染通道的名称及 LayerMask 一致；\n\n" +
                "3. 在 Scene 窗体下，Unity 只设置了单摄像机进行绘制，因此热扭曲虽然被设置到其他层级单独渲染，但在 Scene 模式下会和 Default 层一起渲染，也就是多绘制了一次。表现上会有颜色叠加的可能。因此实际效果以 Game 窗体内显示的为准；\n", h);
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