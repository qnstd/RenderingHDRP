using UnityEditor;
using static UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInBaseShaderGUI;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��׼���� ShaderGUI
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class LitStandardShaderGUI : NodeShaderGUI
    {
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            // ��������
            Gui.Space(10);
            DrawTex("��������ͼ", ShaderPropIDs.ID_AlbedoTex, ShaderPropIDs.ID_AlbedoColor, editor, props);
            Gui.Space(2);
            DrawTex("������ͼ", ShaderPropIDs.ID_NormalTex, editor, props);
            Gui.Space(2);
            Gui.IndentLevelAdd(2);
            if (!IsNullTex(ShaderPropIDs.ID_NormalTex, props))
                DrawRange("����ǿ��", ShaderPropIDs.ID_NormalStrength, editor, props);
            Gui.IndentLevelSub(2);
            Gui.Space(2);
            DrawTex("PBR������ͼ", ShaderPropIDs.ID_MaskTex, editor, props);
            Gui.IndentLevelAdd(2);
            if (!IsNullTex(ShaderPropIDs.ID_MaskTex, props))
            {
                FindProperty(ShaderPropIDs.ID_UseRemapping, props).floatValue = 1;
                DrawMaxMinSlider(ShaderPropIDs.ID_MetallicRemapping, 0, 1, "������", editor, props);
                DrawMaxMinSlider(ShaderPropIDs.ID_SmoothRemapping, 0, 1, "ƽ����", editor, props);
                DrawMaxMinSlider(ShaderPropIDs.ID_AORemapping, 0, 1, "AO", editor, props);
            }
            else
            {
                FindProperty(ShaderPropIDs.ID_UseRemapping, props).floatValue = 0;
                DrawRange("������", ShaderPropIDs.ID_Metallic, editor, props);
                DrawRange("ƽ����", ShaderPropIDs.ID_Smooth, editor, props);
            }
            Gui.IndentLevelSub(2);
            Gui.Space(2);
            DrawTex("������ͼ", ShaderPropIDs.ID_CoatTex, ShaderPropIDs.ID_Coat, editor, props);
            if ((SurfaceType)FindProperty("_SurfaceType", props).floatValue == SurfaceType.Transparent)
            {
                Gui.Space(2);
                DrawRange("͸����", ShaderPropIDs.ID_Alpha, editor, props);
            }
            Gui.Space(2);
            DrawDefault(ShaderPropIDs.ID_TillingAndOffset, "��ͼ������ƫ��", editor, props);


            // ϸ��
            DrawTex("ϸ����ͼ", ShaderPropIDs.ID_DetailTex, editor, props);
            if (!IsNullTex(ShaderPropIDs.ID_DetailTex, props))
            {
                Gui.IndentLevelAdd(2);
                DrawDefault(ShaderPropIDs.ID_LockAlbedoTillingAndOffset, "������������ͼ�����ż�ƫ��", editor, props);
                DrawDefault(ShaderPropIDs.ID_DetailTillingAndOffset, "����ƫ��", editor, props);
                DrawRange("������ǿ��", ShaderPropIDs.ID_DetailAlbedoScal, editor, props);
                DrawRange("����ǿ��", ShaderPropIDs.ID_DetailNormalScal, editor, props);
                DrawRange("ƽ����ǿ��", ShaderPropIDs.ID_DetailSmoothnessScal, editor, props);
                Gui.IndentLevelSub(2);
            }


            // �Է���
            Gui.Space(10);
            DrawDefault(ShaderPropIDs.ID_EmissionTex, "�Է�����ͼ", editor, props);
            Gui.IndentLevelAdd();
            DrawDefault(ShaderPropIDs.ID_EmissionClr, "�����ɫ", editor, props);
            DrawDefault(ShaderPropIDs.ID_MultiplyAlbedo, "�Ƿ񽫷����ʲ����Է�����", editor, props);
            DrawDefault(ShaderPropIDs.ID_ExposureWeight, "�ع�Ȩ��", editor, props);
            Gui.IndentLevelSub();

        }
    }
}

