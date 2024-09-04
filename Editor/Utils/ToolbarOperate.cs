using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// �Զ��� Toolbar 
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public static class ToolbarOperate
    {
        static readonly Type ToolbarType = typeof(UnityEditor.Editor).Assembly.GetType("UnityEditor.Toolbar");
        static ScriptableObject toolbar = null;


        /// <summary>
        /// �����Զ��� Toolbar ����
        /// </summary>
        static public void Draw()
        {
            if (toolbar == null)
            {
                // ��unity��Դ���в�ѯ UnityEditor.Toolbar ���͵����ж��󣬲���ȡ Toolbar ����
                UnityEngine.Object[] toolbars = Resources.FindObjectsOfTypeAll(ToolbarType);
                toolbar = (toolbars.Length > 0) ? (ScriptableObject)toolbars[0] : null;
                if (toolbar != null)
                {
                    // ͨ�������ȡ�� Toolbar �µ� m_Root ����������ֵ
                    FieldInfo root = toolbar.GetType().GetField("m_Root", BindingFlags.NonPublic | BindingFlags.Instance);
                    VisualElement ve = root.GetValue(toolbar) as VisualElement;
                    // ��ȡ toolbar ������
                    VisualElement zone = ve.Q("ToolbarZoneLeftAlign");
                    // ����Զ���� toolbar ��Ϣ
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


        // �����Զ�����Ϣ
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