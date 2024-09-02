
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
            Gui.Label("��������Ե��");
            Gui.IndentLevelAdd();
            Gui.Space(3);
            DrawDefault(ShaderPropIDs.ID_FresnelColor, "��ɫ", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelArea, "��Χ", editor, props);
            DrawDefault(ShaderPropIDs.ID_FresnelForce, "ǿ��", editor, props);
            Gui.Space(3);
            Gui.IndentLevelSub();
        }
    }
}