using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 通用 ShaderGUI Inspector 编辑器
    /// <para>作者：强辰</para>
    /// </summary>
    public class GeneralEditorShaderGUI : ShaderGUI
    {
        //自定义单行图片展示
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

        //自定义 Foldout 显示效果
        internal class FoldoutDrawer : MaterialPropertyDrawer
        {
            bool show = true;
            public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
            {
                // 用于第一次打开材质面板，以 Shader 文件属性的 Foldout 值来进行折叠显示
                show = (prop.floatValue == 1) ? true : false;
                // 用于手动控制 Foldout 折叠
                show = EditorGUILayout.Foldout(show, label);
                // 更新值
                prop.floatValue = Convert.ToSingle(show);
            }
            public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
            {
                return 0;
            }
        }


        #region 变量
        public class MaterialData
        {
            public MaterialProperty m_prop; //材质属性
            public bool m_indentLevel = false; //属性显示时是否进行缩进
            public bool m_childIndentLv = false; //属性中子属性是否需要缩进
            public bool m_disabled = false; //属性是否可操作
            public string m_helpdesc = null; //属性说明
            public string m_foldoutName = null; // Foldout 名称
        }

        protected Dictionary<string, MaterialProperty> m_MaterialProperty = new Dictionary<string, MaterialProperty>(); //存储材质中所有属性
        protected List<MaterialData> m_MaterialDataList = new List<MaterialData>(); //存储自定义材质数据，自定义数据包含材质属性及显示是否缩进信息（但这里不包含 Foldout 为关闭状态时，其子节点的显示）
        #endregion


        /// <summary>
        /// 检测属性是否在着色器属性显示列表内
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
        /// 针对可在 Inspector 面板中显示的着色器属性进一步筛选（此函数会在基类筛选操作完毕后执行。子类重写）
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

            //组织数据
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
                        Match match = Regex.Match(item, @"(\w+)\s*\((.*)\)"); //匹配格式：(\w+)字母、下划线、字符1个或多个，\s* 匹配空格0个或多个， \((.*)\) 匹配任意字符0个或多个
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

            //进一步筛选
            FurtherSelect(materialEditor, properties);

            //绘制
            MaterialData md;
            for (int i = 0; i < m_MaterialDataList.Count; i++)
            {
                md = m_MaterialDataList[i];
                MaterialProperty prop = md.m_prop; //属性
                bool indentLevel = md.m_indentLevel; //是否需要缩进
                bool childIndentlv = md.m_childIndentLv; //子元素是否需要缩进
                bool disabled = md.m_disabled; //属性是否可操作
                string helpdesc = md.m_helpdesc; //帮助说明

                if (prop.name.StartsWith("_SplitBar"))
                {// 分隔条
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

                if ((prop.flags & (MaterialProperty.PropFlags.HideInInspector | MaterialProperty.PropFlags.PerRendererData)) == MaterialProperty.PropFlags.None) //HideInInspector 和 PerRendererData 标记的属性不进行绘制
                {
                    float propertyHeight = materialEditor.GetPropertyHeight(prop, prop.displayName);
                    Rect controlRect = EditorGUILayout.GetControlRect(true, propertyHeight, EditorStyles.layerMaskField);

                    if (indentLevel) Gui.IndentLevelAdd();
                    if (childIndentlv) Gui.IndentLevelAdd();

                    //属性
                    Gui.Disabled(disabled);
                    materialEditor.ShaderProperty(controlRect, prop, prop.displayName); //绘制属性项
                    Gui.EndDisabled();

                    //属性对应的帮助说明显示
                    if (!string.IsNullOrEmpty(helpdesc))
                    {
                        Gui.Help(helpdesc);
                    }

                    if (childIndentlv) Gui.IndentLevelSub();
                    if (indentLevel) Gui.IndentLevelSub();
                }
            }

            //Unity 材质默认项
            Gui.Space(5);
            if (SupportedRenderingFeatures.active.editableMaterialRenderQueue)
            {//如果支持渲染功能中渲染队列的动态设置，则显示。
                materialEditor.RenderQueueField();
            }
            //显示GPU实例操作项
            materialEditor.EnableInstancingField();
            //显示双边GI操作项
            materialEditor.DoubleSidedGIField();

            //说明
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