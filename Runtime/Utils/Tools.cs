using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{

    /// <summary>
    /// 工具包（包含Editor）
    /// <para>作者：强辰</para>
    /// </summary>
    public class Tools
    {
        #region 字节转字符串
        static string[] C_UNITS = new string[] { "B", "KB", "MB", "GB", "TB", "PB" };
        static public string Bytes2Str(long val, bool isunits = true, string format = "f1")
        {
            return Bytes2Str(val, isunits, format);
        }
        static public string Bytes2Str(ulong val, bool isunits = true, string format = "f1")
        {
            double _val = val;
            double mod = 1024.0;
            int i = 0;
            while (_val >= mod)
            {
                _val /= mod;
                i++;
            }
            return _val.ToString(format) + (isunits ? C_UNITS[i] : "");
        }
        #endregion



        /// <summary>
        /// 秒数转时间
        /// <para>格式：00:00 （分:秒）</para>
        /// </summary>
        /// <param name="seconds">秒数</param>
        /// <returns></returns>
        static public string Seconds2Time(int seconds)
        {
            int v = seconds;
            int m = v / 60;
            int s = v % 60;
            return string.Format("{0:D2}:{1:D2}", m, s);
        }


        /// <summary>
        /// 分辨率更改
        /// </summary>
        /// <param name="lastResolution">上次分辨率</param>
        /// <param name="resolution">分辨率参照</param>
        /// <param name="act">分辨率比列计算完毕后续操作的委托</param>
        static public void CaluResolutionScale(ref Vector2 lastResolution, Vector2 resolution, Action<float> act)
        {
            int curw = Screen.width;
            int curh = Screen.height;
            if (lastResolution.x != curw || lastResolution.y != curh)
            {
                lastResolution.Set(curw, curh);
                float wscale = lastResolution.x / resolution.x;
                float hscale = lastResolution.y / resolution.y;
                float scale = (wscale <= hscale) ? wscale : hscale;
                // 更新
                act?.Invoke(scale);
            }
        }


        /// <summary>
        /// 创建一张单颜色的纹理
        /// </summary>
        /// <param name="size">尺寸</param>
        /// <param name="c">颜色</param>
        /// <returns></returns>
        static public Texture2D CreateT2D(int size, Color c)
        {
            Texture2D t2d = new Texture2D(size, size);
            for (int i = 0; i < t2d.width; i++)
            {
                for (int j = 0; j < t2d.height; j++)
                {
                    t2d.SetPixel(i, j, c);
                }
            }
            t2d.Apply();
            return t2d;
        }


        /// <summary>
        /// 将字符串复制到剪贴板
        /// </summary>
        /// <param name="str"></param>
        static public void Clipboard(string str)
        {
            GUIUtility.systemCopyBuffer = str;
        }


        // 编辑器模式下使用的脚本
#if UNITY_EDITOR

        /// <summary>
        /// 定位SceneView元素
        /// </summary>
        /// <param name="obj">游戏对象</param>
        /// <param name="showSceneView">是否同时在 SceneView 窗体下将焦点移动到参数对象</param>
        static public void LocationElement(UnityEngine.Object obj, bool showSceneView = true)
        {
            if (obj == null) { return; }
            EditorGUIUtility.PingObject(obj);
            Selection.activeObject = obj;
            if (showSceneView)
                SceneView.lastActiveSceneView.FrameSelected();
        }


        /// <summary>
        /// 在 Graphi 渲染库目录获取文件
        /// </summary>
        /// <param name="relpath">相对着色库根目录的子目录集</param>
        /// <param name="filename">文件名</param>
        /// <returns></returns>
        static public string FindexactFile(string relpath, string filename)
        {
            string p = Path.Combine
                        (
                            "Packages/com.cngraphi.renderhdrp",
                            relpath,
                            filename
                        );
            p = p.Replace("\\", "/");
            //p = Path.GetFullPath(p); // 获取已打包资源的绝对路径

            if (File.Exists(p))
            {
                return p;
            }
            return null;
        }


        /// <summary>
        /// 获取类型中变量的信息（CustomPass）
        /// </summary>
        /// <param name="t"></param>
        /// <param name="customPass"></param>
        /// <param name="lst"></param>
        public static void GetFieldInfo
            (
                Type t,
                SerializedProperty customPass,
                ref List<Field> lst
            )
        {
            lst.Clear();
            FieldInfo[] fields = t.GetFields(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
            foreach (FieldInfo fi in fields)
            {
                lst.Add(new Field()
                {
                    Prop = customPass.FindPropertyRelative(fi.Name),
                    Attr = fi.GetCustomAttribute<FieldAttr>()
                });
            }
        }


        /// <summary> 
        /// 获取类型中变量的信息（Inspector）
        /// </summary>
        /// <param name="t"></param>
        /// <param name="so"></param>
        /// <param name="lst"></param>
        static public void GetFieldInfo
            (
                Type t,
                SerializedObject so,
                ref List<Field> lst
            )
        {
            lst.Clear();
            FieldInfo[] fields = t.GetFields(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
            foreach (FieldInfo fi in fields)
            {
                lst.Add(new Field()
                {
                    Prop = so.FindProperty(fi.Name),
                    Attr = fi.GetCustomAttribute<FieldAttr>()
                });
            }
        }


        /// <summary>
        /// 显示变量信息（CustomPass）
        /// </summary>
        /// <param name="lst"></param>
        /// <param name="rect"></param>
        /// <param name="GetH"></param>
        public static void ShowFieldInfo(List<Field> lst, ref Rect rect, Func<SerializedProperty, float, float> GetH)
        {
            Field f;
            FieldAttr attr;
            for (int i = 0; i < lst.Count; i++)
            {
                f = lst[i];
                attr = f.Attr;
                EditorGUI.indentLevel += attr.IndentLevel;
                EditorGUI.PropertyField(rect, f.Prop, new GUIContent(attr.Label), true);
                rect.y += GetH(f.Prop, 0);
                EditorGUI.indentLevel -= attr.IndentLevel;
                if (!string.IsNullOrEmpty(attr.Detail))
                    EditorGUILayout.HelpBox(attr.Detail, MessageType.None);
            }
        }
        /// <summary>
        /// 显示变量信息（Inspector）
        /// </summary>
        /// <param name="lst"></param>
        static public void ShowFieldInfo(List<Field> lst)
        {
            Field f;
            FieldAttr attr;
            for (int i = 0; i < lst.Count; i++)
            {
                f = lst[i];
                attr = f.Attr;
                EditorGUI.indentLevel += attr.IndentLevel;

                EditorGUILayout.PropertyField(f.Prop, new GUIContent(attr.Label));
                if (!string.IsNullOrEmpty(attr.Detail))
                    EditorGUILayout.HelpBox(attr.Detail, MessageType.None);

                EditorGUI.indentLevel -= attr.IndentLevel;
                EditorGUILayout.Space(3);
            }
        }
#endif


    }
}