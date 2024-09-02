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
            Gui.Label("��Ĥ����");
            Gui.Space(3);
            Gui.IndentLevelAdd();

            DrawRange("������", ShaderPropIDs.ID_IorThickness, editor, props);
            DrawRange("����ǿ��", ShaderPropIDs.ID_IorIntensity, editor, props);

            Gui.IndentLevelSub();
        }
    }
}