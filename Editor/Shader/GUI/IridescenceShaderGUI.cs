using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��Ĥ���� ShaderGUI
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class IridescenceShaderGUI : NodeShaderGUI
    {
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            Gui.Label("Iridescence");
            Gui.Space(3);
            Gui.IndentLevelAdd();

            DrawRange("Thickness", ShaderPropIDs.ID_IorThickness, editor, props);
            DrawRange("Force", ShaderPropIDs.ID_IorIntensity, editor, props);

            Gui.IndentLevelSub();
        }
    }
}