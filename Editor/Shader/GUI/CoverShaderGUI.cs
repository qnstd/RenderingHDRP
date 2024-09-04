using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 着色器 - 颜色混合类型枚举
    /// <para>用于在Inspector中实现颜色混合选项卡的自定义样式。</para>
    /// <para>作者：强辰</para>
    /// </summary>
    public enum BlendColorType
    {// 以下名称顺序应与 BlendColorKind.shadergraph 文件定义的一致
        Burn,
        LinearBurn,
        Darken,
        Overwrite,
        Overlay,
        Lighten,
        VividLight,
        LinearLight,
        Multiply,
        Subtract,
        Divide,
        Difference,
        Exclusion,
        Negation,
        LinearDodge,
        LinearLightAddSub,
        SoftLight,
        HardMix,
        Dodge,
        HardLight,
        PinLight,
        Filter,
        Add
    }

    /// <summary>
    /// 覆盖色 ShaderGUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class CoverShaderGUI : NodeShaderGUI
    {
        private BlendColorType m_BlendType = BlendColorType.Add;

        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            DrawDefault(ShaderPropIDs.ID_CoverFlag, "Cover", editor, props);
            Gui.Space(3);

            if (Find(ShaderPropIDs.ID_CoverFlag, props).floatValue == 1)
            {
                Gui.IndentLevelAdd();
                DrawTex("Tex", ShaderPropIDs.ID_CoverMap, editor, props);

                Gui.IndentLevelAdd();
                Gui.Space(5);
                if (!IsNullTex(ShaderPropIDs.ID_CoverMap, props))
                {
                    // r
                    DrawChannel("R channel", ShaderPropIDs.ID_RFlag, ShaderPropIDs.ID_R, ShaderPropIDs.ID_RBright, editor, props);
                    // g
                    DrawChannel("G channel", ShaderPropIDs.ID_GFlag, ShaderPropIDs.ID_G, ShaderPropIDs.ID_GBright, editor, props);
                    // b
                    DrawChannel("B channel", ShaderPropIDs.ID_BFlag, ShaderPropIDs.ID_B, ShaderPropIDs.ID_BBright, editor, props);
                    // a
                    DrawChannel("A channel", ShaderPropIDs.ID_AFlag, ShaderPropIDs.ID_A, ShaderPropIDs.ID_ABright, editor, props);

                    Gui.Space(3);
                    DrawDefault(ShaderPropIDs.ID_BlendFlag, "Blend", editor, props);
                    if (Find(ShaderPropIDs.ID_BlendFlag, props).floatValue == 1)
                    {
                        Gui.Space(2);
                        Gui.IndentLevelAdd();
                        m_BlendType = Gui.EnumPop<BlendColorType>("BlendType", m_BlendType);
                        Find(ShaderPropIDs.ID_BlendType, props).floatValue = (float)m_BlendType;
                        DrawDefault(ShaderPropIDs.ID_BlendFactor, "BlendFactor", editor, props);
                        Gui.IndentLevelSub();
                    }
                    Gui.Space(2);
                    Gui.Help(
                        "1. Color mixing is the processing when there are overlapping areas of each channel. If there is no overlapping area between channels during the design, it is recommended to turn off the color mixing processing module to save performance overhead；\n" +
                        "2. If the color mixing processing module is turned off and there is a superposition area between different channels, the method of \"color adding\" is used for mixing；\n" +
                        "3. When all four channels are not opened, the mixing operation cannot be performed even if the color mixing is enabled；"
                        ,
                        UnityEditor.MessageType.None);

                    Gui.Space(3);
                    DrawDefault(ShaderPropIDs.ID_CoverThreshold, "Threshold", editor, props);
                    Gui.Help("The function of the width value is to solve the problem of pixels with too low gray value in the overlay color map, resulting in broken points (black blocks) during the overlay color. Generally, the default value is 0.1. The larger the value, the more color is drawn.", MessageType.None);
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
                DrawDefault(colorname, "Color", editor, props);
                DrawDefault(brightnessname, "Brightness", editor, props);
            }
            Gui.IndentLevelSub(2);
        }
    }
}