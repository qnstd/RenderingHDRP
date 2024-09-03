
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��������Ե����Ӱ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class FresnelShaderGUI : NodeShaderGUI
    {
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            Gui.Label("Fresnel Light");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawDefault(ShaderPropIDs.ID_FresnelColor, "Color", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelArea, "Area", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelForce, "Force", editor, props);
            Gui.Space(3);
            Gui.IndentLevelSub();
        }
    }
}