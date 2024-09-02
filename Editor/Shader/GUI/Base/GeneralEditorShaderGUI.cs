using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ͨ�� ShaderGUI Inspector �༭��
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class GeneralEditorShaderGUI : ShaderGUI
    {
        //�Զ��嵥��ͼƬչʾ
        internal class SingleLineDrawer : MaterialPropertyDrawer
        {
            public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
            {
                editor.TexturePropertySingleLine(label, prop);
            }
            public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
            {
                return 0;
            }
        }

        //�Զ��� Foldout ��ʾЧ��
        internal class FoldoutDrawer : MaterialPropertyDrawer
        {
            bool show = true;
            public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
            {
                // ���ڵ�һ�δ򿪲�����壬�� Shader �ļ����Ե� Foldout ֵ�������۵���ʾ
                show = (prop.floatValue == 1) ? true : false;
                // �����ֶ����� Foldout �۵�
                show = EditorGUILayout.Foldout(show, label);
                // ����ֵ
                prop.floatValue = Convert.ToSingle(show);
            }
            public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
            {
                return 0;
            }
        }


        #region ����
        public class MaterialData
        {
            public MaterialProperty m_prop; //��������
            public bool m_indentLevel = false; //������ʾʱ�Ƿ��������
            public bool m_childIndentLv = false; //�������������Ƿ���Ҫ����
            public bool m_disabled = false; //�����Ƿ�ɲ���
            public string m_helpdesc = null; //����˵��
            public string m_foldoutName = null; // Foldout ����
        }

        protected Dictionary<string, MaterialProperty> m_MaterialProperty = new Dictionary<string, MaterialProperty>(); //�洢��������������
        protected List<MaterialData> m_MaterialDataList = new List<MaterialData>(); //�洢�Զ���������ݣ��Զ������ݰ����������Լ���ʾ�Ƿ�������Ϣ�������ﲻ���� Foldout Ϊ�ر�״̬ʱ�����ӽڵ����ʾ��
        #endregion


        /// <summary>
        /// ��������Ƿ�����ɫ��������ʾ�б���
        /// </summary>
        /// <param name="propname"></param>
        /// <returns></returns>
        protected MaterialData InMaterialDataList(string propname)
        {
            MaterialData data;
            for (int i = 0; i < m_MaterialDataList.Count; i++)
            {
                data = m_MaterialDataList[i];
                if (data.m_prop.name == propname) { return data; }
            }
            return null;
        }



        /// <summary>
        /// ��Կ��� Inspector �������ʾ����ɫ�����Խ�һ��ɸѡ���˺������ڻ���ɸѡ������Ϻ�ִ�С�������д��
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="properties"></param>
        protected virtual void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties) { }


        /// <summary>
        /// GUI
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="properties"></param>
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            m_MaterialDataList.Clear();
            m_MaterialProperty.Clear();

            //��֯����
            Shader shader = (materialEditor.target as Material).shader;
            for (int i = 0; i < properties.Length; i++)
            {
                var propertie = properties[i];
                m_MaterialProperty[propertie.name] = propertie;
                m_MaterialDataList.Add(new MaterialData() { m_prop = propertie, m_indentLevel = false });
                var attrs = shader.GetPropertyAttributes(i);
                foreach (var item in attrs)
                {
                    if (item.StartsWith("To"))
                    {
                        Match match = Regex.Match(item, @"(\w+)\s*\((.*)\)"); //ƥ���ʽ��(\w+)��ĸ���»��ߡ��ַ�1��������\s* ƥ��ո�0�������� \((.*)\) ƥ�������ַ�0������
                        if (match.Success)
                        {
                            var name = match.Groups[2].Value.Trim();
                            int inx = m_MaterialDataList.Count - 1;
                            m_MaterialDataList[inx].m_foldoutName = name;
                            if (m_MaterialProperty.TryGetValue(name, out var a))
                            {
                                if (a.floatValue == 0f)
                                {
                                    m_MaterialDataList.RemoveAt(inx);
                                    break;
                                }
                                else { m_MaterialDataList[inx].m_indentLevel = true; }
                            }
                        }
                    }
                }
            }

            //��һ��ɸѡ
            FurtherSelect(materialEditor, properties);

            //����
            MaterialData md;
            for (int i = 0; i < m_MaterialDataList.Count; i++)
            {
                md = m_MaterialDataList[i];
                MaterialProperty prop = md.m_prop; //����
                bool indentLevel = md.m_indentLevel; //�Ƿ���Ҫ����
                bool childIndentlv = md.m_childIndentLv; //��Ԫ���Ƿ���Ҫ����
                bool disabled = md.m_disabled; //�����Ƿ�ɲ���
                string helpdesc = md.m_helpdesc; //����˵��

                if (prop.name.StartsWith("_SplitBar"))
                {// �ָ���
                    Gui.Space(10);
                    if (indentLevel) Gui.IndentLevelAdd();
                    if (childIndentlv) Gui.IndentLevelAdd();
                    GUIStyle sty = new GUIStyle("dragtabdropwindow");
                    sty.richText = true;
                    sty.fontSize = 11;
                    Gui.Label(helpdesc, sty);
                    if (childIndentlv) Gui.IndentLevelSub();
                    if (indentLevel) Gui.IndentLevelSub();
                    continue;
                }

                if ((prop.flags & (MaterialProperty.PropFlags.HideInInspector | MaterialProperty.PropFlags.PerRendererData)) == MaterialProperty.PropFlags.None) //HideInInspector �� PerRendererData ��ǵ����Բ����л���
                {
                    float propertyHeight = materialEditor.GetPropertyHeight(prop, prop.displayName);
                    Rect controlRect = EditorGUILayout.GetControlRect(true, propertyHeight, EditorStyles.layerMaskField);

                    if (indentLevel) Gui.IndentLevelAdd();
                    if (childIndentlv) Gui.IndentLevelAdd();

                    //����
                    Gui.Disabled(disabled);
                    materialEditor.ShaderProperty(controlRect, prop, prop.displayName); //����������
                    Gui.EndDisabled();

                    //���Զ�Ӧ�İ���˵����ʾ
                    if (!string.IsNullOrEmpty(helpdesc))
                    {
                        Gui.Help(helpdesc);
                    }

                    if (childIndentlv) Gui.IndentLevelSub();
                    if (indentLevel) Gui.IndentLevelSub();
                }
            }

            //Unity ����Ĭ����
            Gui.Space(5);
            if (SupportedRenderingFeatures.active.editableMaterialRenderQueue)
            {//���֧����Ⱦ��������Ⱦ���еĶ�̬���ã�����ʾ��
                materialEditor.RenderQueueField();
            }
            //��ʾGPUʵ��������
            materialEditor.EnableInstancingField();
            //��ʾ˫��GI������
            materialEditor.DoubleSidedGIField();

            //˵��
            DrawHelpDesc();
        }


        protected Vector2 m_v2 = Vector2.zero;
        protected virtual void DrawHelpDesc(string desc = "", int h = 150)
        {
            if (string.IsNullOrEmpty(desc)) { return; }
            Gui.Space(10);
            m_v2 = Gui.Scroll(m_v2, h);
            Gui.Disabled();
            GUIStyle sty = new GUIStyle("Tooltip");
            sty.fontSize = 10;
            sty.richText = true;
            EditorGUILayout.TextArea(desc, sty);
            Gui.EndDisabled();
            Gui.EndScroll();
        }

    }
}