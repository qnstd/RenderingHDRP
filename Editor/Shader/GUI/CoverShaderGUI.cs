using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ����ɫ ShaderGUI
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class CoverShaderGUI : NodeShaderGUI
    {
        private BlendColorType m_BlendType = BlendColorType.Add;

        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            DrawDefault(ShaderPropIDs.ID_CoverFlag, "����ɫ", editor, props);
            Gui.Space(3);

            if (Find(ShaderPropIDs.ID_CoverFlag, props).floatValue == 1)
            {
                Gui.IndentLevelAdd();
                DrawTex("������ͼ", ShaderPropIDs.ID_CoverMap, editor, props);

                Gui.IndentLevelAdd();
                Gui.Space(5);
                if (!IsNullTex(ShaderPropIDs.ID_CoverMap, props))
                {
                    // r
                    DrawChannel("ͨ��1��R��", ShaderPropIDs.ID_RFlag, ShaderPropIDs.ID_R, ShaderPropIDs.ID_RBright, editor, props);
                    // g
                    DrawChannel("ͨ��2��G��", ShaderPropIDs.ID_GFlag, ShaderPropIDs.ID_G, ShaderPropIDs.ID_GBright, editor, props);
                    // b
                    DrawChannel("ͨ��3��B��", ShaderPropIDs.ID_BFlag, ShaderPropIDs.ID_B, ShaderPropIDs.ID_BBright, editor, props);
                    // a
                    DrawChannel("ͨ��4��A��", ShaderPropIDs.ID_AFlag, ShaderPropIDs.ID_A, ShaderPropIDs.ID_ABright, editor, props);

                    Gui.Space(3);
                    DrawDefault(ShaderPropIDs.ID_BlendFlag, "��ɫ���", editor, props);
                    if (Find(ShaderPropIDs.ID_BlendFlag, props).floatValue == 1)
                    {
                        Gui.Space(2);
                        Gui.IndentLevelAdd();
                        m_BlendType = Gui.EnumPop<BlendColorType>("�������", m_BlendType);
                        Find(ShaderPropIDs.ID_BlendType, props).floatValue = (float)m_BlendType;
                        DrawDefault(ShaderPropIDs.ID_BlendFactor, "�������", editor, props);
                        Gui.IndentLevelSub();
                    }
                    Gui.Space(2);
                    Gui.Help(
                        "1. ��ɫ�������Ը�ͨ�����ڵ�������ʱ�Ĵ����������ʱ�������ڸ�ͨ���໥�������򣬽���ر���ɫ��ϴ���ģ���Խ�ʡ���ܿ�����\n" +
                        "2. ����ɫ��ϴ���ģ�鴦�ڹر�״̬�£��Ҵ��ڲ�ͬͨ��֮��ĵ����������ա���ɫ��ӡ��ķ�ʽ���л�ϣ�\n" +
                        "3. ��4��ͨ��ȫ��δ����ʱ����ʹ��������ɫ��ϣ�Ҳ�޷����л�ϲ�����"
                        ,
                        UnityEditor.MessageType.None);

                    Gui.Space(3);
                    DrawDefault(ShaderPropIDs.ID_CoverThreshold, "��ֵ", editor, props);
                    Gui.Help("��ֵ�������ǽ������ɫ��ͼ�д��ڻҶ�ֵ���͵����أ��Ӷ����¸�����ɫʱ�����Ƶ㣨�ڿ飩���⡣һ��Ĭ��ֵ0.1���ɡ���ֵԽ�󣬳�ɫԽ�ࡣ", MessageType.None);
                }
                Gui.IndentLevelSub();

                Gui.IndentLevelSub();
            }
        }

        private void DrawChannel(string label, string flagname, string colorname, string brightnessname, MaterialEditor editor, MaterialProperty[] props)
        {
            DrawDefault(flagname, label, editor, props);
            Gui.IndentLevelAdd(2);
            if (Find(flagname, props).floatValue == 1)
            {
                DrawDefault(colorname, "��ɫ", editor, props);
                DrawDefault(brightnessname, "����", editor, props);
            }
            Gui.IndentLevelSub(2);
        }
    }
}