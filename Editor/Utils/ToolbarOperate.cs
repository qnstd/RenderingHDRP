using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 自定义 Toolbar 
    /// <para>作者：强辰</para>
    /// </summary>
    public static class ToolbarOperate
    {
        static readonly Type ToolbarType = typeof(UnityEditor.Editor).Assembly.GetType("UnityEditor.Toolbar");
        static ScriptableObject toolbar = null;


        /// <summary>
        /// 绘制自定义 Toolbar 窗体
        /// </summary>
        static public void Draw()
        {
            if (toolbar == null)
            {
                // 从unity资源库中查询 UnityEditor.Toolbar 类型的所有对象，并获取 Toolbar 对象。
                UnityEngine.Object[] toolbars = Resources.FindObjectsOfTypeAll(ToolbarType);
                toolbar = (toolbars.Length > 0) ? (ScriptableObject)toolbars[0] : null;
                if (toolbar != null)
                {
                    // 通过反射获取到 Toolbar 下的 m_Root 变量及变量值
                    FieldInfo root = toolbar.GetType().GetField("m_Root", BindingFlags.NonPublic | BindingFlags.Instance);
                    VisualElement ve = root.GetValue(toolbar) as VisualElement;
                    // 获取 toolbar 的区域
                    VisualElement zone = ve.Q("ToolbarZoneLeftAlign");
                    // 添加自定义的 toolbar 信息
                    VisualElement parent = new VisualElement()
                    {
                        style = { flexGrow = 1, flexDirection = FlexDirection.Row }
                    };
                    IMGUIContainer container = new IMGUIContainer();
                    container.onGUIHandler += OnGui;
                    parent.Add(container);
                    zone.Add(parent);
                }
            }
        }


        static GUIStyle sty = null;
        static Texture2D logoTex2D = null;


        // 绘制自定义信息
        static void OnGui()
        {
            if (logoTex2D == null)
                logoTex2D = AssetDatabase.LoadAssetAtPath<Texture2D>(ProjectUtils.FindexactFile("Editor/Images", "Graphi-Logo-Little.png"));
            if (sty == null)
                sty = new GUIStyle("IN EditColliderButton") { fontSize = 11, richText = true, alignment = TextAnchor.MiddleRight };


            Color c = GUI.backgroundColor;
            GUI.backgroundColor = Color.green;
            Gui.Btn("<color=#ffffff>Graphi  </color>", () => { SettingsService.OpenProjectSettings("Project/Graphi Rendering HDRP"); }, sty, Gui.W(70), Gui.H(22));
            GUI.backgroundColor = c;

            GUI.DrawTexture(new Rect(6, 2, 17, 17), logoTex2D);
        }
    }

}