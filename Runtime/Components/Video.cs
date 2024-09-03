using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Video;


namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 视频宽高比
    /// <para>作者：强辰</para>
    /// </summary>
    public enum VideoAspect
    {
        /// <summary>
        /// Free Aspect
        /// </summary>
        Free,
        /// <summary>
        /// 16:9
        /// </summary>
        A16_9,
        /// <summary>
        /// 9:16
        /// </summary>
        A9_16,
        /// <summary>
        /// 16:10
        /// </summary>
        A16_10,
        /// <summary>
        /// 10:16
        /// </summary>
        A10_16,
        /// <summary>
        /// 21:9
        /// </summary>
        A21_9,
        /// <summary>
        /// 9:21
        /// </summary>
        A9_21,
        /// <summary>
        /// 2:1
        /// </summary>
        A2_1,
        /// <summary>
        /// 1:2
        /// </summary>
        A1_2,
        /// <summary>
        /// 4:3
        /// </summary>
        A4_3,
        /// <summary>
        /// 3;4
        /// </summary>
        A3_4,
        /// <summary>
        /// 5:4
        /// </summary>
        A5_4,
        /// <summary>
        /// 4:5
        /// </summary>
        A4_5,
        /// <summary>
        /// 1:1
        /// </summary>
        A1_1,
    }



    /// <summary>
    /// 视频播放器
    /// <para>作者：强辰</para>
    /// </summary>
    [ExecuteInEditMode]
    [DisallowMultipleComponent]
    // 必须包含的组件
    [RequireComponent(typeof(MeshFilter))]
    [RequireComponent(typeof(MeshRenderer))]
    [RequireComponent(typeof(VideoPlayer))]
    public class Video : MonoBehaviour
    {
        #region 系列化参数
        public VideoAspect m_Aspect = VideoAspect.A16_9;
        public Vector2 m_Size = new Vector2(1.0f, 0.5625f);
        public VideoSource m_Source = VideoSource.VideoClip;
        public VideoClip m_Clip = null;
        public string m_URL = "";
        public Material m_Mat = null;
        #endregion



        VideoPlayer vplayer = null;
        MeshRenderer mshRender = null;
        MeshFilter mshFilter = null;
        Mesh msh = null;


        void Start()
        {
            CalculateRenderSize((int)m_Aspect, m_Size);
            msh = CreateQuad(m_Size);
            mshFilter = transform.GetComponent<MeshFilter>();
            mshFilter.sharedMesh = msh;
            mshFilter.hideFlags = HideFlags.NotEditable;

            mshRender = transform.GetComponent<MeshRenderer>();
            mshRender.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            mshRender.sharedMaterial = m_Mat;
            mshRender.hideFlags = HideFlags.NotEditable;

            vplayer = transform.GetComponent<VideoPlayer>();
            vplayer.isLooping = true;
            vplayer.renderMode = VideoRenderMode.MaterialOverride;
            vplayer.hideFlags = HideFlags.NotEditable;

            switch (m_Source)
            {
                case VideoSource.VideoClip:
                    SetVideo(m_Clip, Application.isPlaying);
                    break;
                case VideoSource.Url:
                    SetVideo(m_URL, Application.isPlaying);
                    break;
            }
        }


        void OnDestroy()
        {
            m_URL = null;
            m_Clip = null;
            if (vplayer != null)
            {
                vplayer.Stop();
                vplayer.clip = null;
                vplayer = null;
            }
            if (mshFilter != null && mshFilter.sharedMesh != null)
            {
                DestroyImmediate(mshFilter.sharedMesh);
                if (msh != null)
                {
                    msh.Clear();
                }
            }
            msh = null;
            mshRender = null;
            mshFilter = null;
        }


        private Mesh CreateQuad(Vector2 size, string name = "QuadMesh")
        {
            Mesh mesh = new Mesh();
            mesh.name = name;

            // 顶点
            mesh.vertices = CreateVertices(size);

            // 三角形
            int[] tris = new int[6]
            {
            0, 2, 1,
            2, 3, 1
            };
            mesh.triangles = tris;

            // 法线
            Vector3[] normals = new Vector3[4]
            {
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward
            };
            mesh.normals = normals;

            // uv
            Vector2[] uv0s = new Vector2[4]
            {
            new Vector2(0, 0),
            new Vector2(1, 0),
            new Vector2(0, 1),
            new Vector2(1, 1)
            };
            mesh.uv = uv0s;

            return mesh;
        }

        Vector3[] CreateVertices(Vector2 size)
        {
            float _x = size.x * 0.5f;
            float _y = size.y * 0.5f;
            Vector3[] vertexs = new Vector3[4]
            {
            new Vector3(-_x, -_y, 0),
            new Vector3(_x, -_y, 0),
            new Vector3(-_x, _y, 0),
            new Vector3(_x, _y, 0)
            };
            return vertexs;
        }


        /// <summary>
        /// 重置网格顶点信息
        /// </summary>
        /// <param name="newsize">新的尺寸</param>
        public void ResetMeshVertices(Vector2 newsize)
        {
            if (mshFilter == null) { return; }
            Mesh msh = mshFilter.sharedMesh;
            if (msh == null) { return; }

            m_Size = newsize;
            msh.vertices = CreateVertices(m_Size);
        }


        /// <summary>
        /// 计算实际的网格渲染尺寸
        /// </summary>
        /// <param name="e">宽高比类型枚举值</param>
        /// <param name="s">尺寸</param>
        public Vector2 CalculateRenderSize(int e, Vector2 s)
        {
            string val = Enum.Parse(typeof(VideoAspect), e.ToString()).ToString();
            if (val == "Free")
            {
                m_Size = s;
            }
            else
            {
                string[] strs = val.Split("_");
                int haspect = int.Parse(strs[1]);
                int waspect = int.Parse(strs[0].Substring(1));
                m_Size = new Vector2
                (
                    s.x,
                    s.x * haspect / waspect
                );
            }
            return m_Size;
        }

        /// <summary>
        /// 设置视频
        /// </summary>
        /// <param name="clip">视频</param>
        /// <param name="isPlay">在设置完毕后是否进行播放</param>
        public void SetVideo(VideoClip clip, bool isPlay = false)
        {
            if (vplayer == null) { return; }
            if (vplayer.source != VideoSource.VideoClip) { return; }

            vplayer.Stop();
            m_Clip = clip;
            vplayer.clip = m_Clip;
            if (isPlay)
            {
                vplayer.Play();
            }
        }

        /// <summary>
        /// 设置视频
        /// </summary>
        /// <param name="URL">视频URL</param>
        /// <param name="isPlay">在设置完毕后是否进行播放</param>
        public void SetVideo(string URL, bool isPlay = false)
        {
            if (vplayer == null) { return; }
            if (vplayer.source != VideoSource.Url) { return; }

            vplayer.Stop();
            m_URL = URL;
            vplayer.url = m_URL;
            if (isPlay)
            {
                vplayer.Play();
            }
        }

        /// <summary>
        /// 播放器
        /// </summary>
        public VideoPlayer Player { get { return vplayer; } }

        /// <summary>
        /// 视频
        /// </summary>
        public VideoClip Clip { get { return m_Clip; } }

        /// <summary>
        /// URL
        /// </summary>
        public string URL { get { return m_URL; } }

        /// <summary>
        /// 渲染器
        /// </summary>
        public MeshRenderer Renderer { get { return mshRender; } }

    }



#if UNITY_EDITOR
    [CustomEditor(typeof(Video))]
    public class VideoEditor : Editor
    {
        Video src = null;
        VideoPlayer player = null;

        SerializedProperty m_Aspect = null;
        SerializedProperty m_Size = null;
        SerializedProperty m_Source = null;
        SerializedProperty m_Clip = null;
        SerializedProperty m_URL = null;
        SerializedProperty m_Mat = null;


        float m_Frame = 0;
        string m_TimeInfo = "00:00 / 00:00";
        Rect m_drawControlArea = new Rect(0, 0, 260, 115);

        GUIStyle btnStyle = null;


        public void OnEnable()
        {
            src = (Video)target;
            player = src.Player;

            m_Aspect = serializedObject.FindProperty("m_Aspect");
            m_Size = serializedObject.FindProperty("m_Size");
            m_Source = serializedObject.FindProperty("m_Source");
            m_Clip = serializedObject.FindProperty("m_Clip");
            m_URL = serializedObject.FindProperty("m_URL");
            m_Mat = serializedObject.FindProperty("m_Mat");

            ChangeFrame();
        }


        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.Space(5);

            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_Aspect, new GUIContent("Aspect"));
            if (EditorGUI.EndChangeCheck())
            {
                ChangeAspectAndSize(m_Aspect.intValue, m_Size.vector2Value);
            }


            EditorGUILayout.Space(3);
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_Size, new GUIContent("Size"));
            if (EditorGUI.EndChangeCheck())
            {
                ChangeAspectAndSize(m_Aspect.intValue, m_Size.vector2Value);
            }


            EditorGUILayout.Space(3);
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_Mat, new GUIContent("Material"));
            if (EditorGUI.EndChangeCheck())
            {
                ChangeMat();
            }

            EditorGUILayout.Space(3);
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_Source, new GUIContent("DataSource"));
            if (EditorGUI.EndChangeCheck())
            {
                ChangeSource();
            }
            EditorGUILayout.Space(3);
            EditorGUI.indentLevel += 2;
            switch ((VideoSource)m_Source.intValue)
            {
                case VideoSource.VideoClip:
                    DrawVideoSourceGUI(m_Clip, "Clip");
                    break;
                case VideoSource.Url:
                    EditorGUILayout.BeginHorizontal();
                    DrawVideoSourceGUI(m_URL, "URL（file:// or http/https）");
                    Color c = GUI.backgroundColor;
                    GUI.backgroundColor = Color.green;
                    if (GUILayout.Button("...", GUILayout.Width(30), GUILayout.Height(18)))
                    {
                        GUI.FocusControl(null);
                        SelectLocalVideo();
                    }
                    GUI.backgroundColor = c;
                    EditorGUILayout.EndHorizontal();
                    break;
            }
            EditorGUI.indentLevel -= 2;

            serializedObject.ApplyModifiedProperties();
        }


        void DrawVideoSourceGUI(SerializedProperty p, string content)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(p, new GUIContent(content));
            if (EditorGUI.EndChangeCheck())
            {
                ChangeVideo();
            }
        }


        protected virtual void OnSceneGUI()
        {
            if (btnStyle == null)
                btnStyle = new GUIStyle("LargeButton") { richText = true, fontSize = 10 };

            if (player != null && player.frame >= 0 && player.isPlaying)
            {
                m_Frame = (float)player.frame / player.frameCount;
                SetTimeInfo();
            }

            if (!Application.isPlaying)
            {
                Handles.BeginGUI();
                Rect r = SceneView.lastActiveSceneView.position;
                m_drawControlArea.x = r.width - m_drawControlArea.width;
                m_drawControlArea.y = r.height - m_drawControlArea.height;
                GUILayout.BeginArea(m_drawControlArea, "Video Control", "dragtabdropwindow");
                EditorGUILayout.Space(25);

                // 绘制
                GUILayout.BeginVertical();
                EditorGUI.BeginChangeCheck();
                m_Frame = EditorGUILayout.Slider(m_Frame, 0, 1);
                if (EditorGUI.EndChangeCheck())
                {
                    ChangeFrame();
                }

                EditorGUILayout.Space(5);
                GUILayout.BeginHorizontal();
                GUILayout.Label(m_TimeInfo); // 时间
                EditorGUILayout.Space(1);
                Color c = GUI.backgroundColor;
                GUI.backgroundColor = Color.green;
                float _w = 34, _h = 17;
                if (GUILayout.Button("Play", btnStyle, GUILayout.Width(_w), GUILayout.Height(_h)))
                {
                    VideoPlayStopPause(1);
                }
                GUI.backgroundColor = Color.yellow;
                if (GUILayout.Button("Stop", btnStyle, GUILayout.Width(_w), GUILayout.Height(_h)))
                {
                    VideoPlayStopPause(3);
                }
                GUI.backgroundColor = Color.red;
                if (GUILayout.Button("Pause", btnStyle, GUILayout.Width(_w), GUILayout.Height(_h)))
                {
                    VideoPlayStopPause(2);
                }
                GUI.backgroundColor = c;
                GUILayout.EndHorizontal();
                GUILayout.EndVertical();
                // 绘制结束

                GUILayout.EndArea();
                Handles.EndGUI();
            }
        }



        // 设置进度时间字符信息
        void SetTimeInfo()
        {
            m_TimeInfo = $"{((m_Frame == 0) ? "00:00" : Seconds2Time((int)(m_Frame * player.length)))} / {Seconds2Time((int)player.length)}";
        }

        string Seconds2Time(int seconds)
        {
            int v = seconds;
            int m = v / 60;
            int s = v % 60;
            return string.Format("{0:D2}:{1:D2}", m, s);
        }

        // 材质发生改变
        void ChangeMat()
        {
            src.Renderer.sharedMaterial = (Material)m_Mat.boxedValue;
        }

        // 点击进度条
        void ChangeFrame()
        {
            if (!Application.isPlaying)
            {
                if (player == null || player.clip == null) { return; }

                player.Stop();
                int len = (int)(m_Frame * player.frameCount);
                player.frame = len;
                SetTimeInfo();
                player.Play();
                player.Pause();
            }
        }

        // 视频源类型改变
        void ChangeSource()
        {
            FrameZero();
            if (player == null) { return; }
            player.source = (VideoSource)m_Source.intValue;
        }

        // 视频停止并归位进度条和时间
        void FrameZero()
        {
            if (player == null) { return; }
            player.Stop();
            m_Frame = 0;
            SetTimeInfo();
        }

        // 播放控制键
        void VideoPlayStopPause(int val)
        {
            if (player != null)
            {
                switch (val)
                {
                    case 1:
                        player.Play();
                        break;
                    case 2:
                        FrameZero();
                        break;
                    case 3:
                        player.Pause();
                        break;
                }
            }
        }

        // 改变宽高比
        void ChangeAspectAndSize(int e, Vector2 s)
        {
            m_Size.vector2Value = src.CalculateRenderSize(e, s);
            src.ResetMeshVertices(m_Size.vector2Value);
        }


        // 选择本地视频
        void SelectLocalVideo()
        {
            string p = EditorUtility.OpenFilePanel("Select Video", "Assets", null);
            if (!string.IsNullOrEmpty(p))
            {
                p = "file://" + p;
                m_URL.stringValue = p;
                ChangeVideo();
            }
            GUIUtility.ExitGUI();
        }

        // 视频变更
        void ChangeVideo()
        {
            switch ((VideoSource)m_Source.intValue)
            {
                case VideoSource.VideoClip:
                    VideoClip clip = (VideoClip)m_Clip.boxedValue;
                    src.SetVideo(clip);
                    if (clip == null)
                        FrameZero();
                    break;
                case VideoSource.Url:
                    string url = m_URL.stringValue;
                    src.SetVideo(url);
                    if (string.IsNullOrEmpty(url))
                        FrameZero();
                    break;
            }
        }

    }
#endif
}