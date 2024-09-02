using System.Collections.Generic;
using System.Text;
using Unity.Profiling;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 运行时性能检测器
    /// <para>检测器本身占用 SetPass Call 及 Batches 数据中的各一次</para>
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class RuntimePerformance : MonoBehaviour
    {
        /// <summary>
        /// 显示类型
        /// </summary>
        public enum E_ShowTyp
        {
            None, // 无（但对外提供各项数据的接口，这些接口以静态方式提供）
            Console, // 控制台打印
            GUI // 传统 GUI 绘制
        }


        #region GUI变量
        bool m_CanDraw = false;
        readonly Vector2 C_Size4K = new Vector2(3840, 2160); // 4k尺寸
        Vector2 m_LastResolution;
        internal Rect m_DrawRect;
        internal GUIStyle m_DrawStyle;
        Texture2D m_DrawTxtBackground; // 背景纹理
        Rect m_DrawBgRect = new Rect(); // 背景纹理绘制区域
        readonly Vector2 C_DrawBgSize = new Vector2(1300, 1700); // 背景纹理标准尺寸 
        #endregion

        #region Inspector 控制属性
        public E_ShowTyp m_ShowType = E_ShowTyp.GUI;
        public float m_UpdateInterval = 1.0f;
        public int m_DrawSize = 30;
        public Vector2 m_DrawArea = new Vector2(10, 5);
        public Vector2 m_PerforInterval = new Vector2(0.7f, 0.5f);
        public bool m_ExtremelyAustere = false;
        #endregion

        #region FPS计算时需要的变量
        float m_TimeSurplus; // 当前间隔的剩余时间
        float m_LastSample; // 上一次的时间
        float m_Acc = 0.0f; // 在间隔时间内fps的累积
        float m_Frames = 0; // 在间隔时间内绘制的帧
        #endregion

        #region 监测数据变量
        // Fps
        static float m_FpsMillSec = 0f; // 每帧的毫秒值
        static float m_Fps = 15.0f; // 当前FPS值

        // Profiler
        string[] m_Units = new string[] { "B", "KB", "MB", "GB", "TB", "PB" };
        string[] m_Boundary = new string[] { "", "万", "亿" };
        struct ProfilerData
        {
            public string key; // 数据索引。与 Unity 内部名称一致。
            public string desc; // 描述信息
            public bool importance; // 是否标记为重要数据
            public string newline; // 换行符
            public bool byteTransfer; // 是否需要将数值进行变换（针对字节的）
        }
        static readonly ProfilerData[] m_ProfilerKeys = new ProfilerData[]
        {
            // 一帧内切换着色器的次数（主要检测本项，GPU切换着色器渲染类型代价要比 DC 高）
            new ProfilerData(){ key="SetPass Calls Count", desc="切换着色器次数  (SPC)", importance=true, byteTransfer = false, newline="\n\n"},
            // 一帧内向GPU提供渲染游戏对象所需的数据次数（包括动、静态批处理，非SRP批处理）
            new ProfilerData(){ key="Draw Calls Count", desc="提交数据的总次数  (DC)", importance=true, byteTransfer = false, newline="\n"},
            // 一帧内总共的批次总数（包含动、静态）
            new ProfilerData(){ key="Batches Count", desc="执行合批（动、静态）的次数  (Batches)", importance=true, byteTransfer = false, newline="\n"},
            
            // /////////////////////////////////////////////////////////////////
            // 编辑环境下
#if UNITY_EDITOR

            new ProfilerData(){key="Dynamic Batched Draw Calls Count,Dynamic Batches Count",desc="  ---|[<color='#999999ff'> 动态批处理 </color>] 绘制调用次数（DC）: {0} / 批处理次数（Batches）: {1}", importance=false, byteTransfer=false, newline="\n"},
            new ProfilerData(){key="Static Batched Draw Calls Count,Static Batches Count",desc="  ---|[<color='#999999ff'> 静态批处理 </color>] 绘制调用次数（DC）: {0} / 批处理次数（Batches）: {1}", importance=false, byteTransfer=false, newline="\n"},
            new ProfilerData(){key="Instanced Batched Draw Calls Count,Instanced Batches Count",desc="  ---|[<color='#999999ff'>  GPU实例 </color>] 绘制调用次数（DC）: {0} / 批处理次数（Batches）: {1}", importance=false, byteTransfer=false, newline="\n"},

#endif
            // 结束
            // /////////////////////////////////////////////////////////////////

            // 顶点数量 
            new ProfilerData(){ key="Vertices Count", desc="顶点数  (Vertices)", importance=true, byteTransfer = false, newline="\n"},
            // 三角面数量
            new ProfilerData(){ key="Triangles Count", desc="三角面  (Triangles)", importance=true, byteTransfer = false, newline="\n"},
            // 参与投影的游戏对象数量
            new ProfilerData(){ key="Shadow Casters Count", desc="参与投影计算的游戏对象总数  (ShadowCasters)", importance=true, byteTransfer = false, newline="\n\n"},


            //// ---------------------------------------------------------------
            //// --在发布后的数据比在Editor环境下要准确

            // 每帧使用的 RenderTexture 的数量及内存占用
            new ProfilerData(){ key="Render Textures Count", desc="使用的纹理总数  (RT Count)", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Render Textures Bytes", desc="使用的纹理占用内存总数  (RT Size)", importance=false, byteTransfer = true, newline="\n"},
            // 每帧中设置一个或者多个RT作为渲染目标次数（切换RT渲染目标）
            new ProfilerData(){ key="Render Textures Changes Count", desc="切换渲染目标的次数  (RT Target SwitchNumber)", importance=false, byteTransfer = false, newline="\n\n"},
            // 使用GPU缓冲区的总数及内存总数。包含顶点、顶点索引、计算缓冲区及渲染需要的所有内部缓冲区
            new ProfilerData(){ key="Used Buffers Count", desc="缓冲区使用总数  (GPU Buffer Count)", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Used Buffers Bytes", desc="缓冲区使用内存总数  (GPU Buffer Size)", importance=false, byteTransfer = true, newline="\n"},
            // 每帧 CPU 提交到 GPU 的几何体数量（包含顶点、法线、UV数据）
            new ProfilerData(){ key="Vertex Buffer Upload In Frame Count", desc="---| 提交顶点、法线、UV数据的总数  (VertexBuffer Upload Count InFrame)", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Vertex Buffer Upload In Frame Bytes", desc="---| 提交顶点、法线、UV数据的尺寸  (VertexBuffer Upload Size InFrame)", importance=false, byteTransfer = true, newline="\n"},
            // 每帧 CPU 提交到 GPU 的几何体数量（包含三角面的索引数据）
            new ProfilerData(){ key="Index Buffer Upload In Frame Count", desc="---| 提交三角面的总数  (IndexBuffer Upload Count InFrame)", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Index Buffer Upload In Frame Bytes", desc="---| 提交三角面的尺寸  (IndexBuffer Upload Size InFrame)", importance=false, byteTransfer = true, newline="\n"},

            //// --结束
            //// ---------------------------------------------------------------
        };
        List<ProfilerRecorder> m_ProfilerRecords = new List<ProfilerRecorder>();

        // 显示的信息文本串
        StringBuilder INFO = new StringBuilder();
        #endregion

        #region 对外接口【静态】
        /// <summary>
        /// FPS
        /// </summary>
        static public float FPS { get { return m_Fps; } }
        /// <summary>
        /// FPS 毫秒值
        /// </summary>
        static public float FPSMilliSec { get { return m_FpsMillSec; } }
        /// <summary>
        /// 绘制开关
        /// <para>当为绘制模式时，此属性才被激活</para>
        /// </summary>
        static public bool DrawFlag { get; set; } = false;
        #endregion


        void OnEnable()
        {
            for (int i = 0; i < m_ProfilerKeys.Length; i++)
            {
                ProfilerData pd = m_ProfilerKeys[i];
                string k = pd.key;
                int indx = k.IndexOf(",");
                if (indx == -1)
                    m_ProfilerRecords.Add(ProfilerRecorder.StartNew(ProfilerCategory.Render, k));
                else
                {
                    string[] keys = k.Split(",");
                    for (int j = 0; j < keys.Length; j++)
                    {
                        m_ProfilerRecords.Add(ProfilerRecorder.StartNew(ProfilerCategory.Render, keys[j]));
                    }
                }
            }
            m_DrawTxtBackground = Tools.CreateT2D(4, new UnityEngine.Color(0, 0, 0, 0.5f));
        }

        void OnDisable()
        {
            int len = m_ProfilerRecords.Count;
            for (int i = len - 1; i >= 0; i--)
            {
                m_ProfilerRecords[i].Dispose();
            }
            m_ProfilerRecords.Clear();
            if (m_DrawTxtBackground != null) { GameObject.DestroyImmediate(m_DrawTxtBackground); m_DrawTxtBackground = null; }
        }

        void Start()
        {
            m_DrawRect = new Rect(m_DrawArea.x, m_DrawArea.y, 0, 0);

            m_TimeSurplus = m_UpdateInterval;
            m_LastSample = Time.realtimeSinceStartup;
        }

        void Update()
        {
            // 计算FPS
            ++m_Frames;

            float newSample = Time.realtimeSinceStartup;
            float delta = newSample - m_LastSample;
            m_LastSample = newSample;

            m_Acc += 1.0f / delta; //因每段时间差内（当前帧时间 - 上一帧时间）只触发一次帧，那么可以计算出本次时间差内的FPS值（以 '单位秒' 为单位，比如：0.5/s）
            m_TimeSurplus -= delta;
            if (m_TimeSurplus <= 0.0f)
            {
                m_Fps = m_Acc / m_Frames; // FPS平均值 = 间隔时间内每段触发时的FPS累加之和 / 间隔时间内的触发次数
                m_FpsMillSec = 1000.0f / m_Fps;

                m_TimeSurplus = m_UpdateInterval;
                m_Acc = 0.0f;
                m_Frames = 0;

                // 显示各项数据。Profiler数据的更新以FPS更新的时段为准。
                switch (m_ShowType)
                {
                    case E_ShowTyp.None:
                        m_CanDraw = false;
                        break;
                    case E_ShowTyp.Console:
                        m_CanDraw = false;
                        Lg.Trace(InfoForamt());
                        break;
                    case E_ShowTyp.GUI:
                        m_CanDraw = true;
                        break;
                }
            }
        }

        void OnGUI()
        {
            if (m_DrawStyle == null)
            {
                m_DrawStyle = new GUIStyle("AM EffectName") { richText = true, fontSize = m_DrawSize };
            }

            if (m_CanDraw && DrawFlag)
            {
                Tools.CaluResolutionScale(ref m_LastResolution, C_Size4K, (scale) =>
                {
                    m_DrawStyle.fontSize = (int)(m_DrawSize * scale);
                    Vector2 size = C_DrawBgSize * scale;
                    m_DrawBgRect.Set(0, 0, size.x, size.y);
                });
                if (!m_ExtremelyAustere)
                    GUI.DrawTexture(m_DrawBgRect, m_DrawTxtBackground);
                GUI.Label(m_DrawRect, InfoForamt(), m_DrawStyle);
            }
        }


        /// <summary>
        /// 数值进行单位转换
        /// </summary>
        /// <param name="on">是否开启转换</param>
        /// <param name="val">转换值</param>
        /// <param name="mod">被除值</param>
        /// <param name="units">单位</param>
        /// <param name="retain">保留小数多少位</param>
        /// <returns></returns>
        string UnitsTransfer(bool on, long val, double mod, string[] units, string retain = "F2")
        {
            string _value;
            if (!on)
            {
                _value = val.ToString();
            }
            else
            {
                double dval = val;
                int i = 0;
                while (dval >= mod)
                {
                    dval /= mod;
                    i++;
                }
                _value = dval.ToString(retain) + " <color=#ebce89ff>" + units[i] + "</color>";
            }
            return "<color=#c09fdfff>" + _value + "</color>";
        }
        string Transfer(string k, long orignval, bool b)
        {
            return (k == "Vertices Count" || k == "Triangles Count") ? UnitsTransfer(true, orignval, 10000.0, m_Boundary, "F1") : UnitsTransfer(b, orignval, 1024.0, m_Units);
        }


        /// <summary>
        /// 格式化输出信息
        /// </summary>
        /// <returns></returns>
        string InfoForamt()
        {
            //FPS 颜色区分
            int framerate = GraphiMachine.FrameRate;
            string color = "#8fffc1ff"; // 绿
            if (FPS <= framerate * m_PerforInterval.x)
                color = "#fee766ff"; // 黄
            else if (FPS <= framerate * m_PerforInterval.y)
                color = "#fe666dff"; // 红

            // 信息
            INFO.Clear();
            if (m_ExtremelyAustere)
            {
                INFO.Append("<color=" + color + ">FPS: " + FPS.ToString("F1") + " / " + framerate + " - " + FPSMilliSec.ToString("F3") + " ms</color>");
            }
            else
            {
                INFO
                .Append("<color=#ffffffff><b>性能监测器 (Graphi)</b>\n\n")
                // fps
                .Append("   <color=" + color + ">FPS: " + FPS.ToString("F1") + " / " + framerate + " - " + FPSMilliSec.ToString("F3") + " ms</color>\n\n")
                // profiler
                .Append("   <color=#89b5ffff>图形信息（按照每帧计算）</color>\n\n");
                int dataIndex = 0; //数据真正的索引
                for (int i = 0; i < m_ProfilerKeys.Length; i++)
                {
                    ProfilerData pd = m_ProfilerKeys[i];
                    string k = pd.key;
                    string prefix = (pd.importance) ? "<color=#ff7979ff><b>*</b></color> " : ""; // 重要检测项
                    string extra;
                    if (k == "Vertices Count")
                    {
                        extra = "\n";
                        // 额外: 在顶点数的数据前插入一条自定义的数据（节省的批次数量 = 总DC数量 - 合批数量）
                        long savebybatchesNum = GetProfilerData(1) - GetProfilerData(2);
                        INFO.Append("       <color=#ff7979ff><b>*</b></color> <color=#ccccccff>节省的批次数 (Saveby Batches): <color=#8eeb89ff>" + savebybatchesNum + "</color></color>\n");
                    }
                    else { extra = ""; }

                    if (k.IndexOf(",") == -1)
                    {
                        INFO.Append(extra + "       " + prefix + "<color=#ccccccff>" + pd.desc + ": </color>" + Transfer(k, GetProfilerData(dataIndex), pd.byteTransfer) + pd.newline);
                        dataIndex++;
                    }
                    else
                    {
                        string[] ks = k.Split(",");
                        List<string> d = new List<string>();
                        for (int j = 0; j < ks.Length; j++)
                        {
                            d.Add(Transfer(ks[j], GetProfilerData(dataIndex), pd.byteTransfer));
                            dataIndex++;
                        }
                        INFO.Append(extra + "       " + prefix + "<color=#ccccccff>" + string.Format(pd.desc, d.ToArray()) + "</color>" + pd.newline);
                    }
                }
                // systeminfos
                string[] processor = GraphiMachine.SystemProcessor;
                object[] graphics = GraphiMachine.Graphics;
                INFO
                    .Append("\n\n   <color=#89b5ffff>系统信息</color><color=#ccccccff>\n\n")
                    .AppendLine($"       操作系统: {GraphiMachine.SystemOperating}")
                    .AppendLine($"\n       处理器: {processor[0]} / {processor[1]}核 ({processor[2]}MHz)")
                    .AppendLine($"\n       内存: {GraphiMachine.SystemMemory} MB")
                    .AppendLine($"\n       显卡: {graphics[0]}")
                    .AppendLine($"               显存: {graphics[1]} MB")
                    .AppendLine($"               支持版本: {graphics[2]}")
                    .AppendLine($"               支持着色等级: {graphics[3]}")
                    .AppendLine($"               最大图片尺寸: {graphics[4]}")
                    .AppendLine($"               是否支持多线程渲染: {graphics[5]}")
                    .AppendLine($"\n       渲染平台: {GraphiMachine.GraphicsDevice}");
                INFO.Append("</color></color>");
            }

            // 输出
            string s = INFO.ToString();
            INFO.Clear();
            return s;
        }



        /// <summary>
        /// 获取 Profiler 数据
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        long GetProfilerData(int index)
        {
            if (index < 0 || index > m_ProfilerRecords.Count - 1) { return 0; }
            ProfilerRecorder r = m_ProfilerRecords[index];
            return r.Valid ? r.LastValue : 0;
        }

    }


#if UNITY_EDITOR

    /// <summary>
    /// RuntimePerformance 组件Inspector面板
    /// <para>作者：强辰</para>
    /// </summary>
    [CustomEditor(typeof(RuntimePerformance))]
    internal class RuntimePerformanceEditor : UnityEditor.Editor
    {
        RuntimePerformance src;

        SerializedProperty updateInterval;
        SerializedProperty showType;
        SerializedProperty drawSize;
        SerializedProperty drawArea;
        SerializedProperty perforInterval;
        SerializedProperty extremelyAustere;


        private void OnEnable()
        {
            src = target as RuntimePerformance;

            updateInterval = serializedObject.FindProperty("m_UpdateInterval");
            showType = serializedObject.FindProperty("m_ShowType");
            drawSize = serializedObject.FindProperty("m_DrawSize");
            drawArea = serializedObject.FindProperty("m_DrawArea");
            perforInterval = serializedObject.FindProperty("m_PerforInterval");
            extremelyAustere = serializedObject.FindProperty("m_ExtremelyAustere");

        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.Space(5);
            EditorGUILayout.PropertyField(extremelyAustere, new GUIContent("极简模式"));

            EditorGUILayout.Space(10);
            EditorGUILayout.PropertyField(updateInterval, new GUIContent("刷新间隔 (单位：秒)"));

            EditorGUILayout.Space(10);
            EditorGUILayout.PropertyField(showType, new GUIContent("显示类型"));
            switch (showType.intValue)
            {
                case 2: //Gui
                    EditorGUI.indentLevel += 2;

                    EditorGUILayout.Space(4);
                    EditorGUILayout.PropertyField(drawSize, new GUIContent("文本尺寸"));
                    EditorGUILayout.Space(2);
                    EditorGUILayout.PropertyField(drawArea, new GUIContent("绘制位置"));
                    EditorGUILayout.Space(2);
                    EditorGUILayout.PropertyField(perforInterval, new GUIContent("FPS 颜色区间"));

                    EditorGUILayout.Space(10);
                    EditorGUILayout.HelpBox(
                        "   文本尺寸以4k分辨率为基准\n\n" +
                        "   FPS 颜色区间说明\n" +
                        "       x：大于此数值为优秀区间；\n" +
                        "       y：大于此数值并小于等于 x 数值则为中等区间，小于等于此数值则为低效区间；\n\n" +
                        "   * 在此显示模式下，运行时可使用快捷键（ ` ）来快速切换显隐状态。"
                        , MessageType.Info);

                    EditorGUI.indentLevel -= 2;

                    if (src != null)
                    {
                        if (src.m_DrawStyle != null)
                        {
                            src.m_DrawSize = drawSize.intValue;
                            src.m_DrawStyle.fontSize = src.m_DrawSize;
                        }
                        if (src.m_DrawRect != null)
                        {
                            src.m_DrawArea = drawArea.vector2Value;
                            src.m_DrawRect.Set(src.m_DrawArea.x, src.m_DrawArea.y, 0, 0);
                        }
                    }
                    break;
            }

            serializedObject.ApplyModifiedProperties();
        }
    }

#endif
}