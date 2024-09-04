using System;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 编辑模式下的GUI
    /// <para>作者: 强辰</para>
    /// </summary>
    public class Gui
    {
        static public EditorWindow ShowWin<T>(string title, bool utility = false, bool modal = false)
        {
            title = string.IsNullOrEmpty(title) ? "" : title;
            EditorWindow win = EditorWindow.GetWindow(typeof(T), utility);
            win.titleContent = new GUIContent(title);
            if (modal)
                win.ShowModal();
            else
                win.Show();
            return win;
        }
        static public EditorWindow ShowWin<T>(string title, Vector2 size, bool utility = false, bool modal = false)
        {
            title = string.IsNullOrEmpty(title) ? "" : title;
            EditorWindow win = EditorWindow.GetWindow(typeof(T), utility);
            win.titleContent = new GUIContent(title);
            win.maximized = false;
            win.minSize = size;
            win.maxSize = size;
            if (modal)
                win.ShowModal();
            else
                win.Show();
            return win;
        }


        static public void Space(float val) { EditorGUILayout.Space(val); }


        static public void Label(string label, float w = -1, float h = -1)
        {
            if (w == -1 && h == -1)
                EditorGUILayout.LabelField(label);
            else
            {
                if (w == -1 && h != -1)
                    EditorGUILayout.LabelField(label, H(h));
                else if (w != -1 && h == -1)
                    EditorGUILayout.LabelField(label, W(w));
                else
                    EditorGUILayout.LabelField(label, W(w), H(h));
            }
        }
        static public void Label(string label, GUIStyle sty, float w = -1, float h = -1)
        {
            sty.richText = true;
            if (w == -1 && h == -1)
                EditorGUILayout.LabelField(label, sty);
            else
            {
                if (w == -1 && h != -1)
                    EditorGUILayout.LabelField(label, sty, H(h));
                else if (w != -1 && h == -1)
                    EditorGUILayout.LabelField(label, sty, W(w));
                else
                    EditorGUILayout.LabelField(label, sty, W(w), H(h));
            }
        }
        static public void Label(string str, GUIStyle style = null, params GUILayoutOption[] options)
        {
            if (style == null)
                EditorGUILayout.LabelField(str, options);
            else
                EditorGUILayout.LabelField(str, style, options);
        }


        static public GUILayoutOption W(float w) { return GUILayout.Width(w); }
        static public GUILayoutOption H(float h) { return GUILayout.Height(h); }


        static public void Hor(string style = "", params GUILayoutOption[] options) { EditorGUILayout.BeginHorizontal(style, options); }
        static public void Hor(params GUILayoutOption[] options) { EditorGUILayout.BeginHorizontal(options); }
        static public void Hor() { EditorGUILayout.BeginHorizontal(); }
        static public void EndHor() { EditorGUILayout.EndHorizontal(); }


        static public void Vertical() { EditorGUILayout.BeginVertical(); }
        static public void Vertical(string style = "", params GUILayoutOption[] options) { EditorGUILayout.BeginVertical(style, options); }
        static public void Vertical(params GUILayoutOption[] options) { EditorGUILayout.BeginVertical(options); }
        static public void EndVertical() { EditorGUILayout.EndVertical(); }


        static public void Disabled(bool b = true) { EditorGUI.BeginDisabledGroup(b); }
        static public void EndDisabled() { EditorGUI.EndDisabledGroup(); }


        static public void Area(float x, float y, float w, float h) { GUILayout.BeginArea(new Rect(x, y, w, h)); }
        static public void EndArea() { GUILayout.EndArea(); }


        static public Vector2 Scroll(Vector2 v2, params GUILayoutOption[] options) { return EditorGUILayout.BeginScrollView(v2, options); }
        static public Vector2 Scroll(Vector2 v2, GUIStyle style, params GUILayoutOption[] options) { return EditorGUILayout.BeginScrollView(v2, style, options); }
        static public Vector2 Scroll(Vector2 v2, int h = -1)
        {
            if (h <= 0)
                return EditorGUILayout.BeginScrollView(v2);
            else
                return EditorGUILayout.BeginScrollView(v2, H(h));
        }
        static public void EndScroll() { EditorGUILayout.EndScrollView(); }


        static public void Help(string msg, MessageType t = MessageType.Info)
        {
            EditorGUILayout.HelpBox(msg, t);
        }


        static public void IndentLevelAdd() { EditorGUI.indentLevel++; }
        static public void IndentLevelSub() { EditorGUI.indentLevel--; }
        static public void IndentLevelAdd(int val) { EditorGUI.indentLevel += val; }
        static public void IndentLevelSub(int val) { EditorGUI.indentLevel -= val; }


        static public void CreateDragTextfield(ref string val, EditorWindow win, Action<string[]> cb = null, int h = 100)
        {
            Rect rect = EditorGUILayout.GetControlRect(true, h);
            Space(-h);
            val = EditorGUILayout.TextField(val, H(h));

            if (EditorWindow.mouseOverWindow == win && rect.Contains(Event.current.mousePosition))
            {
                if (Event.current.type == EventType.DragUpdated)
                { DragAndDrop.visualMode = DragAndDropVisualMode.Generic; }
                else if (Event.current.type == EventType.DragExited)
                {
                    win.Focus();
                    if (DragAndDrop.paths != null && DragAndDrop.paths.Length != 0)
                    {
                        val = string.Join<string>("\n", DragAndDrop.paths);
                        cb?.Invoke(DragAndDrop.paths);
                    }
                }
            }
        }


        static public T ObjectField<T>(string label, T obj, bool canSelectInHierarchy = false) where T : UnityEngine.Object
        {
            return EditorGUILayout.ObjectField(label, obj, typeof(T), canSelectInHierarchy) as T;
        }


        static public T EnumPop<T>(T obj, params GUILayoutOption[] options) where T : Enum
        {
            return (T)EditorGUILayout.EnumPopup(obj, options);
        }
        static public T EnumPop<T>(T obj, GUIStyle sty, params GUILayoutOption[] options) where T : Enum
        {
            return (T)EditorGUILayout.EnumPopup(obj, sty, options);
        }
        static public T EnumPop<T>(string label, T obj, GUIStyle sty, params GUILayoutOption[] options) where T : Enum
        {
            return (T)EditorGUILayout.EnumPopup(label, obj, sty, options);
        }
        static public T EnumPop<T>(string label, T obj, params GUILayoutOption[] options) where T : Enum
        {
            return (T)EditorGUILayout.EnumPopup(label, obj, options);
        }


        static public float Slider(float val, float min, float max, params GUILayoutOption[] options)
        {
            return EditorGUILayout.Slider(val, min, max, options);
        }


        static bool CreateBtn(string str, GUIStyle sty = null, params GUILayoutOption[] options)
        {
            bool b;
            if (sty == null)
                b = GUILayout.Button(str, options);
            else
                b = GUILayout.Button(str, sty, options);
            return b;
        }
        static public void Btn(string str, Action action, GUIStyle sty = null, params GUILayoutOption[] options)
        {
            if (CreateBtn(str, sty, options)) { action?.Invoke(); }
        }
        static public void Btn(string str, Action<string> action, string p = null, GUIStyle sty = null, params GUILayoutOption[] options)
        {
            if (CreateBtn(str, sty, options)) { action?.Invoke(p); }
        }


        static public void Check() { EditorGUI.BeginChangeCheck(); }
        static public bool EndCheck() { return EditorGUI.EndChangeCheck(); }


        static public Color Color(Color c)
        {
            return EditorGUILayout.ColorField(c);
        }


        static public void Dialog(string msg, string title = "Tip", string ok = "ok")
        {
            msg = (string.IsNullOrEmpty(msg)) ? "" : msg;
            title = (string.IsNullOrEmpty(title)) ? "Tip" : title;
            ok = (string.IsNullOrEmpty(ok)) ? "ok" : ok;
            EditorUtility.DisplayDialog(title, msg, ok);
        }

        static public int Confirm(string msg, string title = "Tip", string ok = "ok", string canc = "cancel")
        {
            msg = (string.IsNullOrEmpty(msg)) ? "" : msg;
            title = (string.IsNullOrEmpty(title)) ? "Tip" : title;
            ok = (string.IsNullOrEmpty(ok)) ? "ok" : ok;
            canc = (string.IsNullOrEmpty(canc)) ? "cancel" : canc;
            return EditorUtility.DisplayDialogComplex(title, msg, ok, canc, "");
        }
    }
}