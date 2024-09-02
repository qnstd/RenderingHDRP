using System;
using System.Collections.Generic;
using UnityEngine;


#if UNITY_EDITOR
using UnityEditor;
#endif


namespace com.graphi.renderhdrp
{
    /// <summary>
    /// LOD 组
    /// <para>作者：强辰</para>
    /// </summary>
    [Serializable]
    public class LODGroup
    {
        [Range(0f, 1f)]
        public float Distance = 1f;
        public List<GameObject> Objs = new List<GameObject>();
    }



    /// <summary>
    /// LOD
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class LOD : MonoBehaviour
    {
        public bool m_OverrideCamera = false;
        public Camera m_Camera = null;
        public float m_MaxDistance = 50.0f;
        public List<LODGroup> m_Groups = new List<LODGroup>();


        // 当前的摄像机
        Camera m_Cam = null;
        // 摄像机与当前对象的距离
        internal float m_Distance = 0;
        // 当前距离比
        float m_CurPercent = 1.0f;
        // 当前所在LOD组索引
        const int LodShowAllIndex = -1; // 全显示
        const int LodCullAllIndex = -2; // 全剔除
        const int LodIndexNone = -3; // 无任何操作，用于清空或默认索引
        int m_LodIndex = LodIndexNone; // 索引：0-n
        // 包含所有的 Transform 对象
        internal Transform[] m_Trans = null;



        /// <summary>
        /// 将当前的 LOD 组索引重置为无任何操作
        /// </summary>
        internal void SetLODNone()
        {
            m_LodIndex = LodIndexNone;
        }


        /// <summary>
        /// 当前 LOD 组索引转显示信息字符
        /// </summary>
        internal string CurrentLodIndex2Str()
        {
            string s;
            switch (m_LodIndex)
            {
                case LodIndexNone:
                    s = "";
                    break;
                case LodCullAllIndex:
                    s = "Cull";
                    break;
                case LodShowAllIndex:
                    s = "All";
                    break;
                default:
                    s = $"LOD {m_LodIndex}";
                    break;
            }
            return s;
        }


        /// <summary>
        /// 更新摄像机
        /// </summary>
        void UpdateCamera()
        {
            if (Application.isPlaying)
            {// 构建、编辑器内的运行时
                m_Cam = (m_OverrideCamera) ? m_Camera : Camera.main;
            }
            else
            {// 非运行时下
#if UNITY_EDITOR
                m_Cam = SceneView.lastActiveSceneView?.camera;
#else
                m_Cam = null;
#endif
            }
        }


        /// <summary>
        /// 重置 Transform 对象数据
        /// </summary>
        internal void ResetTransformData()
        {
            m_Trans = Array.FindAll
                (
                    transform.GetComponentsInChildren<Transform>(true), // 包含active为false的
                    (t) =>
                    {
                        if (t == transform) { return false; } // 去除自身
                        return true;
                    }
                );
        }


        void OnDestroy()
        {
            m_Cam = null;
            m_Distance = 0;
            m_CurPercent = 1.0f;
            if (m_Trans != null)
                Array.Clear(m_Trans, 0, m_Trans.Length);
            m_Trans = null;
        }


        void OnEnable()
        {
            ResetTransformData();
        }

        void OnDisable()
        {
            ShowAll();
            m_LodIndex = LodShowAllIndex;
        }


        void Update()
        {
            if (Application.isPlaying)
                UpdateOperate();
        }

        internal void UpdateOperate()
        {
            if (!this.enabled) { return; }

            UpdateCamera();
            if (m_Cam == null) { return; }

            m_Distance = (m_Cam.transform.position - transform.position).magnitude;
            m_CurPercent = m_Distance / m_MaxDistance;

            int len = m_Groups.Count;
            if (len == 0)
            {// 没有配置 LOD 组的情况下，按照最大距离进行全部显示及全部剔除
                if (m_Distance > m_MaxDistance && m_LodIndex != LodCullAllIndex)
                {
                    m_LodIndex = LodCullAllIndex;
                    Cull();
                }
                else if (m_Distance <= m_MaxDistance && m_LodIndex != LodShowAllIndex)
                {
                    m_LodIndex = LodShowAllIndex;
                    ShowAll();
                }
                return;
            }

            // 配置了 LOD 组，按照每个组的距离比进行显示及剔除
            if (m_CurPercent > m_Groups[len - 1].Distance)
            {// cull 剔除
                if (m_LodIndex != LodCullAllIndex)
                {
                    m_LodIndex = LodCullAllIndex;
                    Cull();
                }
            }
            else
            {
                for (int i = 0; i < len; i++)
                {
                    if (m_CurPercent <= m_Groups[i].Distance)
                    {// 在某一LOD组内
                        if (m_LodIndex != i)
                        {
                            m_LodIndex = i;
                            ChangeLodGroup();  // 执行LOD更换
                        }
                        break;
                    }
                }
            }
        }


        #region 显示、屏蔽相关对象
        internal void ShowAll()
        {
            if (m_Trans == null) { return; }
            Transform t;
            for (int i = 0; i < m_Trans.Length; i++)
            {
                t = m_Trans[i];
                if (t != null)
                {
                    t.gameObject.SetActive(true);
                }
            }
        }
        void Cull()
        {
            if (m_Trans == null) { return; }
            Transform t;
            for (int i = 0; i < m_Trans.Length; i++)
            {
                t = m_Trans[i];
                if (t != null)
                {
                    t.gameObject.SetActive(false);
                }
            }
        }
        internal void ChangeLodGroup()
        {
            List<GameObject> lst = new List<GameObject>();
            int i = m_LodIndex;
            while (i >= 0)
            {
                lst.AddRange(m_Groups[i].Objs.FindAll((e) => { return e != null; }));
                i--;
            }

            Transform t;
            for (int n = 0; n < m_Trans.Length; n++)
            {
                t = m_Trans[n];
                if (t != null)
                {
                    t.gameObject.SetActive((lst.IndexOf(t.gameObject) != -1) ? false : true);
                }
            }
        }
        #endregion
    }




    // Inspector 检视面板
#if UNITY_EDITOR

    [CustomEditor(typeof(LOD))]
    public class LODEditor : Editor
    {
        LOD src = null;

        SerializedProperty m_OverrideCamera;
        SerializedProperty m_Camera;
        SerializedProperty m_MaxDistance;
        SerializedProperty m_Group;

        bool m_GroupFoldout = true;
        bool m_DrawSceneViewLODLabel = true;
        Rect m_DrawRect = new Rect(0, 0, 200, 105);

        #region Style
        GUIStyle m_BoxLabelStyle;
        GUIStyle m_SceneViewLodLabelStyle;
        GUIStyle m_LabelStyle;
        GUIStyle m_BtnStyle;
        private void InitStyle()
        {
            if (m_BoxLabelStyle == null) { m_BoxLabelStyle = new GUIStyle("LODSliderRange") { richText = true, fontSize = 11, alignment = TextAnchor.UpperLeft }; }
            if (m_LabelStyle == null) { m_LabelStyle = new GUIStyle("miniLabel") { richText = true, fontSize = 10, alignment = TextAnchor.MiddleLeft }; }
            if (m_SceneViewLodLabelStyle == null) { m_SceneViewLodLabelStyle = new GUIStyle("LODSliderRange") { richText = true, fontSize = 14, alignment = TextAnchor.MiddleCenter }; }
            if (m_BtnStyle == null) { m_BtnStyle = new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 10 }; }
        }
        #endregion


        private void OnEnable()
        {
            src = target as LOD;

            m_OverrideCamera = serializedObject.FindProperty("m_OverrideCamera");
            m_Camera = serializedObject.FindProperty("m_Camera");
            m_MaxDistance = serializedObject.FindProperty("m_MaxDistance");
            m_Group = serializedObject.FindProperty("m_Groups");
        }


        // 场景视图显示对象的 LOD 级别
        protected virtual void OnSceneGUI()
        {
            if (src != null && src.transform != null)
            {
                // 刷新
                if (!Application.isPlaying)
                    src.UpdateOperate();

                if (m_SceneViewLodLabelStyle != null && src.enabled && m_DrawSceneViewLODLabel)
                {// 绘制标签
                    string info = src.CurrentLodIndex2Str();
                    if (!string.IsNullOrEmpty(info))
                    {
                        // 3D 显示
                        //Transform t = src.transform;
                        //Color c = GUI.backgroundColor;
                        //GUI.backgroundColor = Color.black;
                        //Vector3 p = t.position;
                        //p.y -= 0.3f;
                        //Handles.Label(p, $"{t.name}\n<color=#9fff6f><b>{info}</b></color>\n<color=#cdaa4b>{src.m_Distance.ToString("f3")}m</color>", m_SceneViewLodLabelStyle);
                        //GUI.backgroundColor = c;

                        // 2D 显示
                        Handles.BeginGUI();
                        Rect r = SceneView.lastActiveSceneView.position;
                        m_DrawRect.x = r.width - m_DrawRect.width;
                        m_DrawRect.y = r.height - m_DrawRect.height;
                        GUILayout.BeginArea(m_DrawRect);
                        Color c = GUI.backgroundColor;
                        GUI.backgroundColor = Color.black;
                        GUILayout.Label($"{src.transform.name}\n<color=#9fff6f><b>{info}</b></color>\n<color=#cdaa4b>{src.m_Distance.ToString("f3")}m</color>", m_SceneViewLodLabelStyle);
                        GUI.backgroundColor = c;
                        GUILayout.EndArea();
                        Handles.EndGUI();
                    }
                }
            }
        }


        public override void OnInspectorGUI()
        {
            InitStyle();

            serializedObject.Update();
            EditorGUILayout.Space(5);

            // 摄像机设置
            EditorGUILayout.BeginVertical("box");
            EditorGUILayout.Space(5);
            EditorGUILayout.PropertyField(m_OverrideCamera, new GUIContent("覆盖默认摄像机"));
            EditorGUI.indentLevel++;
            EditorGUI.BeginDisabledGroup(!m_OverrideCamera.boolValue);
            EditorGUILayout.PropertyField(m_Camera, new GUIContent("摄像机"));
            EditorGUI.EndDisabledGroup();
            EditorGUI.indentLevel--;
            EditorGUILayout.Space(5);
            EditorGUILayout.LabelField(
                "<color=#d0ad50>" +
                "1. 在编辑器内处于非运行时状态下，使用的摄像机是场景视图中的摄像机；\n" +
                "2. 默认摄像机使用的是 Tag 标记为 MainCamera 的摄像机；" +
                "</color>",
                m_LabelStyle, GUILayout.Height(30));
            EditorGUILayout.Space(5);
            EditorGUILayout.EndVertical();


            EditorGUILayout.Space(5);
            m_GroupFoldout = EditorGUILayout.Foldout(m_GroupFoldout, new GUIContent("LOD"), true);
            if (m_GroupFoldout)
            {
                EditorGUILayout.Space(5);
                EditorGUILayout.BeginHorizontal();
                m_DrawSceneViewLODLabel = EditorGUILayout.Toggle(m_DrawSceneViewLODLabel, GUILayout.Width(20));
                EditorGUILayout.LabelField("显示场景视图的 LOD 信息公告板");
                EditorGUILayout.EndHorizontal();

                // 绘制LOD组直观图
                EditorGUILayout.Space(5);
                DrawLODGroupPictorialDiagram();
                EditorGUILayout.Space(2);


                // 最大显示距离
                EditorGUILayout.BeginVertical("box");
                EditorGUILayout.Space(5);
                EditorGUILayout.PropertyField(m_MaxDistance, new GUIContent("最大显示距离"), GUILayout.Height(30));
                EditorGUILayout.Space(2);
                EditorGUILayout.EndVertical();


                // LOD 组
                EditorGUILayout.BeginVertical("box");
                EditorGUILayout.Space(5);
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(m_Group, new GUIContent("组"));
                EditorGUI.indentLevel--;

                EditorGUILayout.Space(5);
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.Space(1);
                Color c = GUI.backgroundColor;
                GUI.backgroundColor = Color.HSVToRGB(0.4f, 1, 1);
                if (GUILayout.Button("更新", m_BtnStyle, GUILayout.Width(65), GUILayout.Height(18)))
                {
                    ResetDataAndApplayLod();
                }
                GUI.backgroundColor = c;
                c = GUI.backgroundColor;
                GUI.backgroundColor = Color.yellow;
                if (GUILayout.Button("应用", m_BtnStyle, GUILayout.Width(65), GUILayout.Height(18)))
                {
                    src.SetLODNone();
                }
                GUI.backgroundColor = c;
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.Space(2);
                EditorGUILayout.HelpBox(
                    "注意事项：\n" +
                    "1. Objs 配置组中包含的是需要被屏蔽的对象；\n" +
                    "2. 每一级的 LOD 组都会包含之前 LOD 组配置的屏蔽对象，无需重复配置；\n" +
                    "3. 当组件所绑定的对象其内部结构发生变化（添加、删除、修改等操作）时，需要点击 “更新” 按钮进行数据更新并刷新 LOD 组显示；\n" +
                    "4. 当 LOD 组内相关内容被修改，应点击 “应用” 按钮来刷新 LOD 组显示；", MessageType.Info);
                EditorGUILayout.Space(5);
                EditorGUILayout.EndVertical();
            }

            serializedObject.ApplyModifiedProperties();
        }



        /// <summary>
        /// 重置 Transform 数据及应用 LOD 组
        /// <para>当 LOD 组件所绑定的对象发生了数据结构变化，此时需要对 LOD 组件进行重置及重新应用 LOD 组</para>
        /// </summary>
        private void ResetDataAndApplayLod()
        {
            // 先重新拉取所有Transform对象
            src.ResetTransformData();
            Transform[] datas = src.m_Trans;

            // 对所有的 LOD 组重新执行 Transform 数据匹配
            for (int i = 0; i < m_Group.arraySize; i++)
            {
                SerializedProperty p = m_Group.GetArrayElementAtIndex(i);
                LODGroup g = (LODGroup)p.boxedValue;
                List<GameObject> dels = new List<GameObject>();
                foreach (var obj in g.Objs)
                {
                    int indx = Array.FindIndex(datas, (t) =>
                    {
                        if (obj == null) { return false; }
                        return t == obj.transform;
                    });
                    if (indx == -1)
                    {// 不存在，删除
                        dels.Add(obj);
                    }
                }
                if (dels.Count != 0)
                {
                    foreach (var o in dels)
                        g.Objs.Remove(o);
                    dels.Clear();
                    p.boxedValue = g;
                }
            }

            // 对当前的 LOD 组重置刷新
            src.SetLODNone();
        }



        /// <summary>
        /// 绘制 LOD 组直观图
        /// </summary>
        private void DrawLODGroupPictorialDiagram()
        {
            int len = m_Group.arraySize;
            if (len == 0) { return; }

            float w = EditorGUIUtility.currentViewWidth;
            float _w, _h = 35;
            Color c;

            // draw
            EditorGUILayout.BeginHorizontal();

            // lod draw
            for (int n = 0; n < len; n++)
            {
                LODGroup g = (LODGroup)m_Group.GetArrayElementAtIndex(n).boxedValue;
                _w = (n == 0) ? w * g.Distance : w * g.Distance - w * ((LODGroup)m_Group.GetArrayElementAtIndex(n - 1).boxedValue).Distance;
                c = GUI.backgroundColor;
                GUI.backgroundColor = Color.HSVToRGB(1 * ((n + 1.0f) / len), 1, 0.6f);


                float per = g.Distance;
                string info = $"{(per * 100).ToString("f0")}%，{per * m_MaxDistance.floatValue}m";
                GUILayout.Box($"LOD{n}\n{info}", m_BoxLabelStyle, GUILayout.Width(_w), GUILayout.Height(_h));

                GUI.backgroundColor = c;
            }

            // cull draw
            _w = w * (1 - ((LODGroup)m_Group.GetArrayElementAtIndex(len - 1).boxedValue).Distance);
            if (_w != 0)
            {
                c = GUI.backgroundColor;
                GUI.backgroundColor = Color.black;
                GUILayout.Box("Cull", m_BoxLabelStyle, GUILayout.Width(_w), GUILayout.Height(_h));
                GUI.backgroundColor = c;
            }

            EditorGUILayout.EndHorizontal();
        }
    }


#endif
}