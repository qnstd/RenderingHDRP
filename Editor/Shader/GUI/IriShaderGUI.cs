using UnityEditor;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 薄膜干涉 ShaderGUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class IriShaderGUI : NodeShaderGUI
    {

        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            Gui.Label("Iridescence");
            Gui.Space(3);
            Gui.IndentLevelAdd();
            DrawRange("Force", ShaderPropIDs.ID_IorIntensity, editor, props);
            Gui.Space(3);
            DrawRange("Thickness", ShaderPropIDs.ID_IorThickness, editor, props);
            Gui.IndentLevelSub();
        }
    }
}