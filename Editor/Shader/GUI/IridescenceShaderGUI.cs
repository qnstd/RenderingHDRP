using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 薄膜干涉 ShaderGUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class IridescenceShaderGUI : NodeShaderGUI
    {
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            Gui.Label("薄膜干涉");
            Gui.Space(3);
            Gui.IndentLevelAdd();

            DrawRange("折射厚度", ShaderPropIDs.ID_IorThickness, editor, props);
            DrawRange("折射强度", ShaderPropIDs.ID_IorIntensity, editor, props);

            Gui.IndentLevelSub();
        }
    }
}