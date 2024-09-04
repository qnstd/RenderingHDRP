using System;
using System.Collections.Generic;
using System.Text;
using Unity.Profiling;
using UnityEngine;
using static com.graphi.renderhdrp.GProfiler;



#if UNITY_EDITOR
using UnityEditor;
#endif


namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 图形数据统计
    /// <para>本身占用 SetPass Call 及 Batches 数据中的各一次</para>
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class GProfiler : MonoBehaviour
    {
        /// <summary>
        /// 显示类型
        /// </summary>
        public enum E_ShowTyp
        {
            GUI, // 传统 GUI 绘制
            Console // 控制台打印
        }


        #region GUI变量
        bool m_CanDraw = false;
        readonly Vector2 C_Size4K = new Vector2(3840, 2160); // 4k尺寸
        Vector2 m_LastResolution;
        Rect m_DrawRect;
        GUIStyle m_DrawStyle;
        Texture2D m_DrawTxtBackground; // 背景纹理
        Rect m_DrawBgRect = new Rect(); // 背景纹理绘制区域
        readonly Vector2 C_DrawBgSize = new Vector2(1300, 1700); // 背景纹理标准尺寸 
        #endregion

        #region Inspector 控制属性
        [SerializeField]
        E_ShowTyp m_ShowType = E_ShowTyp.GUI;
        [SerializeField]
        float m_UpdateInterval = 1.0f;
        [SerializeField]
        bool m_ExtremelyAustere = false;
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
        string[] m_Boundary = new string[] { "", "w", "billion" };
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
            new ProfilerData(){ key="SetPass Calls Count", desc="SPC", importance=true, byteTransfer = false, newline="\n\n"},
            // 一帧内向GPU提供渲染游戏对象所需的数据次数（包括动、静态批处理，非SRP批处理）
            new ProfilerData(){ key="Draw Calls Count", desc="DC", importance=true, byteTransfer = false, newline="\n"},
            // 一帧内总共的批次总数（包含动、静态）
            new ProfilerData(){ key="Batches Count", desc="Batches", importance=true, byteTransfer = false, newline="\n"},
            
            // /////////////////////////////////////////////////////////////////
            // 编辑环境下
#if UNITY_EDITOR

            new ProfilerData(){key="Dynamic Batched Draw Calls Count,Dynamic Batches Count",desc="  ---| [<color='#999999ff'> Dynamic </color>] DC: {0} / Batches: {1}", importance=false, byteTransfer=false, newline="\n"},
            new ProfilerData(){key="Static Batched Draw Calls Count,Static Batches Count",desc="  ---| [<color='#999999ff'> Static </color>] DC: {0} / Batches: {1}", importance=false, byteTransfer=false, newline="\n"},
            new ProfilerData(){key="Instanced Batched Draw Calls Count,Instanced Batches Count",desc="  ---| [<color='#999999ff'> GPU Instance </color>] DC: {0} / Batches: {1}", importance=false, byteTransfer=false, newline="\n"},

#endif
            // 结束
            // /////////////////////////////////////////////////////////////////

            // 顶点数量 
            new ProfilerData(){ key="Vertices Count", desc="Vertices", importance=true, byteTransfer = false, newline="\n"},
            // 三角面数量
            new ProfilerData(){ key="Triangles Count", desc="Triangles", importance=true, byteTransfer = false, newline="\n"},
            // 参与投影的游戏对象数量
            new ProfilerData(){ key="Shadow Casters Count", desc="ShadowCasters", importance=true, byteTransfer = false, newline="\n\n"},


            //// ---------------------------------------------------------------
            //// --在发布后的数据比在Editor环境下要准确

            // 每帧使用的 RenderTexture 的数量及内存占用
            new ProfilerData(){ key="Render Textures Count", desc="RT Count", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Render Textures Bytes", desc="RT Size", importance=false, byteTransfer = true, newline="\n"},
            // 每帧中设置一个或者多个RT作为渲染目标次数（切换RT渲染目标）
            new ProfilerData(){ key="Render Textures Changes Count", desc="RT Target SwitchNumber", importance=false, byteTransfer = false, newline="\n\n"},
            // 使用GPU缓冲区的总数及内存总数。包含顶点、顶点索引、计算缓冲区及渲染需要的所有内部缓冲区
            new ProfilerData(){ key="Used Buffers Count", desc="GPU Buffer Count", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Used Buffers Bytes", desc="GPU Buffer Size", importance=false, byteTransfer = true, newline="\n"},
            // 每帧 CPU 提交到 GPU 的几何体数量（包含顶点、法线、UV数据）
            new ProfilerData(){ key="Vertex Buffer Upload In Frame Count", desc="---| VertexBuffer Upload Count InFrame", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Vertex Buffer Upload In Frame Bytes", desc="---| VertexBuffer Upload Size InFrame", importance=false, byteTransfer = true, newline="\n"},
            // 每帧 CPU 提交到 GPU 的几何体数量（包含三角面的索引数据）
            new ProfilerData(){ key="Index Buffer Upload In Frame Count", desc="---| IndexBuffer Upload Count InFrame", importance=false, byteTransfer = false, newline="\n"},
            new ProfilerData(){ key="Index Buffer Upload In Frame Bytes", desc="---| IndexBuffer Upload Size InFrame", importance=false, byteTransfer = true, newline="\n"},

            //// --结束
            //// ---------------------------------------------------------------
        };
        List<ProfilerRecorder> m_ProfilerRecords = new List<ProfilerRecorder>();

        // 显示的信息文本串
        StringBuilder INFO = new StringBuilder();
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
            m_DrawTxtBackground = CreateT2D(4, new UnityEngine.Color(0, 0, 0, 0.5f));
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
            m_DrawRect = new Rect(10, 5, 0, 0);

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
                    case E_ShowTyp.Console:
                        m_CanDraw = false;
                        Debug.Log(InfoForamt());
                        break;
                    case E_ShowTyp.GUI:
                        m_CanDraw = true;
                        break;
                }
            }
        }

        void OnGUI()
        {
            if (m_CanDraw)
            {
                if (m_DrawStyle == null)
                {
                    m_DrawStyle = new GUIStyle("WhiteMiniLabel") { richText = true, fontSize = 30 };
                }

                CaluResolutionScale(ref m_LastResolution, C_Size4K, (scale) =>
                {
                    m_DrawStyle.fontSize = (int)(30 * scale);
                    Vector2 size = C_DrawBgSize * scale;
                    m_DrawBgRect.Set(0, 0, size.x, size.y);
                });
                if (!m_ExtremelyAustere)
                    GUI.DrawTexture(m_DrawBgRect, m_DrawTxtBackground);
                GUI.Label(m_DrawRect, InfoForamt(), m_DrawStyle);
            }
        }


        /// <summary>
        /// 分辨率更改
        /// </summary>
        /// <param name="lastResolution">上次分辨率</param>
        /// <param name="resolution">分辨率参照</param>
        /// <param name="act">分辨率比列计算完毕后续操作的委托</param>
        void CaluResolutionScale(ref Vector2 lastResolution, Vector2 resolution, Action<float> act)
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
        Texture2D CreateT2D(int size, Color c)
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
                _value = $"{dval.ToString(retain)} <color=#ebce89ff>{units[i]}</color>";
            }
            return $"<color=#c09fdfff>{_value}</color>";
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
            // 信息
            INFO.Clear();
            if (m_ExtremelyAustere)
            {
                INFO.Append($"<color=#ffffffff>FPS: {FPS.ToString("F1")} - {FPSMilliSec.ToString("F3")} ms</color>");
            }
            else
            {
                INFO
                .Append("<color=#ffffffff><b>Graphi Profiler</b>\n\n")
                // fps
                .Append($"   FPS: {FPS.ToString("F1")} - {FPSMilliSec.ToString("F3")} ms\n\n")
                // profiler
                .Append("   <color=#89b5ffff>Graphics（PerFrame）</color>\n\n");
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
                        INFO.Append($"       <color=#ff7979ff><b>*</b></color> <color=#ccccccff>Saveby Batches: <color=#8eeb89ff>{savebybatchesNum}</color></color>\n");
                    }
                    else { extra = ""; }

                    if (k.IndexOf(",") == -1)
                    {
                        INFO.Append($"{extra}       {prefix}<color=#ccccccff>{pd.desc}: </color>{Transfer(k, GetProfilerData(dataIndex), pd.byteTransfer)}{pd.newline}");
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
                        INFO.Append($"{extra}       {prefix}<color=#ccccccff>{string.Format(pd.desc, d.ToArray())}</color>{pd.newline}");
                    }
                }
                // systeminfos
                string[] processor = SystemProcessor;
                object[] graphics = Graphics;
                INFO
                    .Append("\n\n   <color=#89b5ffff>System</color><color=#ccccccff>\n\n")
                    .AppendLine($"       OS: {SystemOperating}")
                    .AppendLine($"\n       Processor: {processor[0]} / {processor[1]}core ({processor[2]}MHz)")
                    .AppendLine($"\n       Memory: {SystemMemory} MB")
                    .AppendLine($"\n       Graphics: {graphics[0]}")
                    .AppendLine($"               Memory: {graphics[1]} MB")
                    .AppendLine($"               Version: {graphics[2]}")
                    .AppendLine($"               Level: {graphics[3]}")
                    .AppendLine($"               Max Size: {graphics[4]}")
                    .AppendLine($"               Multiply Thread: {graphics[5]}")
                    .AppendLine($"\n       Target: {GraphicsDevice}");
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


        #region 对外静态接口
        /// <summary>
        /// FPS
        /// </summary>
        static public float FPS { get { return m_Fps; } }
        /// <summary>
        /// FPS 毫秒值
        /// </summary>
        static public float FPSMilliSec { get { return m_FpsMillSec; } }
        /// <summary>
        /// 操作系统
        /// </summary>
        static public string SystemOperating { get { return SystemInfo.operatingSystem; } }
        /// <summary>
        /// 处理器
        /// <para>数组元素依次是：处理器型号、处理器核数、频率MHZ。其中后两个值类型为int。</para>
        /// </summary>
        static public string[] SystemProcessor
        {
            get
            {
                return new string[]
                {
                    SystemInfo.processorType,
                    SystemInfo.processorCount.ToString(),
                    SystemInfo.processorFrequency.ToString()
                };
            }
        }
        /// <summary>
        /// 系统内存
        /// <para>单位：MB</para>
        /// </summary>
        static public int SystemMemory { get { return SystemInfo.systemMemorySize; } }
        /// <summary>
        /// 渲染设备
        /// <para>例如：D3D11</para>
        /// </summary>
        static public string GraphicsDevice
        {
            get
            {
                return Enum.GetName(typeof(UnityEngine.Rendering.GraphicsDeviceType), SystemInfo.graphicsDeviceType);
            }
        }
        /// <summary>
        /// 显卡信息
        /// <para>数组元素依次是：显卡名称、显存（单位：MB）、显卡支持的着色器版本、支持的着色器等级、支持最大纹理尺寸、显卡是否支持多线程操作</para>
        /// </summary>
        static public object[] Graphics
        {
            get
            {
                return new object[]
                {
                    SystemInfo.graphicsDeviceName,      // 显卡名称
                    SystemInfo.graphicsMemorySize,      // 显存（单位：MB）
                    SystemInfo.graphicsDeviceVersion,   // 显卡支持的着色器版本（例如：D3D_11.0-[Level 11.1]）
                    SystemInfo.graphicsShaderLevel,     // 支持的着色器等级（例如：50。对于着色器的 #pragma target 5.0 ）
                    SystemInfo.maxTextureSize,          // 支持最大纹理尺寸
                    SystemInfo.graphicsMultiThreaded    // 显卡是否支持多线程操作
                };
            }
        }
        #endregion
    }


#if UNITY_EDITOR

    /// <summary>
    /// GProfiler 组件Inspector面板
    /// <para>作者：强辰</para>
    /// </summary>
    [CustomEditor(typeof(GProfiler))]
    internal class GProfilerEditor : UnityEditor.Editor
    {
        SerializedProperty updateInterval;
        SerializedProperty showType;
        SerializedProperty extremelyAustere;


        private void OnEnable()
        {
            updateInterval = serializedObject.FindProperty("m_UpdateInterval");
            showType = serializedObject.FindProperty("m_ShowType");
            extremelyAustere = serializedObject.FindProperty("m_ExtremelyAustere");

        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.Space(5);
            EditorGUILayout.PropertyField(updateInterval, new GUIContent("Interval"));

            EditorGUILayout.Space(5);
            EditorGUILayout.PropertyField(showType, new GUIContent("Type"));

            if ((E_ShowTyp)showType.boxedValue == E_ShowTyp.GUI)
            {
                EditorGUILayout.Space(5);
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(extremelyAustere, new GUIContent("Simple Mode"));
                EditorGUI.indentLevel--;
            }

            serializedObject.ApplyModifiedProperties();
        }
    }

#endif
}