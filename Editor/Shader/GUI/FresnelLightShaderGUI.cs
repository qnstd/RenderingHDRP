
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// 菲涅尔边缘光检视板
    /// <para>作者：强辰</para>
    /// </summary>

    public class FresnelLightShaderGUI : NodeShaderGUI
    {
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            Gui.Label("菲涅尔边缘光");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawDefault(ShaderPropIDs.ID_FresnelOffset, "偏移", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelColor, "颜色", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelArea, "范围", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelForce, "强度", editor, props);
            DrawDefault(ShaderPropIDs.ID_MainLightAttenFlag, "主光衰减", editor, props);
            DrawDefault(ShaderPropIDs.ID_MainLightSensitivity, "视线对主光敏感度", editor, props);
            DrawDefault(ShaderPropIDs.ID_MainLightSensitivityPow, "视线对主光敏感度指数", editor, props);
            Gui.Space(3);
            Gui.IndentLevelSub();
        }
    }

}