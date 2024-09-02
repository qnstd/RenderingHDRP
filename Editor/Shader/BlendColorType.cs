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
}