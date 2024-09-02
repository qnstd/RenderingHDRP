using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 覆盖色 ShaderGUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class CoverShaderGUI : NodeShaderGUI
    {
        private BlendColorType m_BlendType = BlendColorType.Add;

        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            DrawDefault(ShaderPropIDs.ID_CoverFlag, "覆盖色", editor, props);
            Gui.Space(3);

            if (Find(ShaderPropIDs.ID_CoverFlag, props).floatValue == 1)
            {
                Gui.IndentLevelAdd();
                DrawTex("覆盖贴图", ShaderPropIDs.ID_CoverMap, editor, props);

                Gui.IndentLevelAdd();
                Gui.Space(5);
                if (!IsNullTex(ShaderPropIDs.ID_CoverMap, props))
                {
                    // r
                    DrawChannel("通道1（R）", ShaderPropIDs.ID_RFlag, ShaderPropIDs.ID_R, ShaderPropIDs.ID_RBright, editor, props);
                    // g
                    DrawChannel("通道2（G）", ShaderPropIDs.ID_GFlag, ShaderPropIDs.ID_G, ShaderPropIDs.ID_GBright, editor, props);
                    // b
                    DrawChannel("通道3（B）", ShaderPropIDs.ID_BFlag, ShaderPropIDs.ID_B, ShaderPropIDs.ID_BBright, editor, props);
                    // a
                    DrawChannel("通道4（A）", ShaderPropIDs.ID_AFlag, ShaderPropIDs.ID_A, ShaderPropIDs.ID_ABright, editor, props);

                    Gui.Space(3);
                    DrawDefault(ShaderPropIDs.ID_BlendFlag, "颜色混合", editor, props);
                    if (Find(ShaderPropIDs.ID_BlendFlag, props).floatValue == 1)
                    {
                        Gui.Space(2);
                        Gui.IndentLevelAdd();
                        m_BlendType = Gui.EnumPop<BlendColorType>("混合类型", m_BlendType);
                        Find(ShaderPropIDs.ID_BlendType, props).floatValue = (float)m_BlendType;
                        DrawDefault(ShaderPropIDs.ID_BlendFactor, "混合因子", editor, props);
                        Gui.IndentLevelSub();
                    }
                    Gui.Space(2);
                    Gui.Help(
                        "1. 颜色混合是针对各通道存在叠加区域时的处理。若在设计时，不存在各通道相互叠加区域，建议关闭颜色混合处理模块以节省性能开销；\n" +
                        "2. 若颜色混合处理模块处于关闭状态下，且存在不同通道之间的叠加区域，则按照“颜色相加”的方式进行混合；\n" +
                        "3. 当4个通道全部未开启时，即使开启了颜色混合，也无法进行混合操作；"
                        ,
                        UnityEditor.MessageType.None);

                    Gui.Space(3);
                    DrawDefault(ShaderPropIDs.ID_CoverThreshold, "阔值", editor, props);
                    Gui.Help("阔值的作用是解决覆盖色贴图中存在灰度值过低的像素，从而导致覆盖上色时出现破点（黑块）问题。一般默认值0.1即可。数值越大，抽色越多。", MessageType.None);
                }
                Gui.IndentLevelSub();

                Gui.IndentLevelSub();
            }
        }

        private void DrawChannel(string label, string flagname, string colorname, string brightnessname, MaterialEditor editor, MaterialProperty[] props)
        {
            DrawDefault(flagname, label, editor, props);
            Gui.IndentLevelAdd(2);
            if (Find(flagname, props).floatValue == 1)
            {
                DrawDefault(colorname, "颜色", editor, props);
                DrawDefault(brightnessname, "亮度", editor, props);
            }
            Gui.IndentLevelSub(2);
        }
    }
}