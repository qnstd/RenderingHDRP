
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 菲涅尔边缘光检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class FresnelShaderGUI : NodeShaderGUI
    {
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            Gui.Label("菲涅尔边缘光");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawDefault(ShaderPropIDs.ID_FresnelColor, "颜色", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelArea, "范围", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelForce, "强度", editor, props);
            Gui.Space(3);
            Gui.IndentLevelSub();
        }
    }
}