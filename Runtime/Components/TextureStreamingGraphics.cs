using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 纹理流数据信息统计窗体
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    public class TextureStreamingGraphics : MonoBehaviour
    {
        #region 绘制相关
        readonly Vector2 C_Size4K = new Vector2(3840, 2160); // 4k尺寸
        Vector2 m_LastResolution;

        GUIStyle m_DrawStyle; // 文本渲染的style
        const int C_DrawSize = 35; // 默认渲染字体尺寸

        Texture2D m_DrawTxtBackground; // 背景纹理
        Rect m_TxtBgRect = new Rect(); // 背景纹理绘制区域
        const float C_SIZE = 1030;
        readonly Vector2 C_TxtBgSize = new Vector2(C_SIZE, 1300); // 背景纹理标准尺寸 
        readonly Vector2 C_HistogramSize = new Vector2(C_SIZE, 400); // 柱状图标准尺寸
        Rect m_HistRect = new Rect(); // 柱状图区域
        Texture2D m_UnusedT2d, m_UsedT2d, m_OptT2d, m_AllT2d, m_MembudgetUseT2d; // 需要显示的柱状图类型

        #endregion


        #region 逻辑变量
        // 纹理实际加载的最高内存（用于内存预算的推荐项）
        static ulong m_MaxDesiredTextureMemory = 0;
        #endregion


        static public ulong MaxDesiredTextureMemory { get { return m_MaxDesiredTextureMemory; } }


        static public bool DrawFlag { get; set; } = false;


        private void OnDestroy()
        {
            m_MaxDesiredTextureMemory = 0;
            if (m_DrawTxtBackground != null){ Destroy(m_DrawTxtBackground); m_DrawTxtBackground = null; }
            if (m_UnusedT2d != null) { Destroy(m_UnusedT2d); m_UnusedT2d = null; }
            if (m_UsedT2d != null) { Destroy(m_UsedT2d); m_UsedT2d = null; }
            if (m_OptT2d != null) { Destroy(m_OptT2d); m_OptT2d = null; }
            if (m_AllT2d != null) { Destroy(m_AllT2d); m_AllT2d = null; }
            if (m_MembudgetUseT2d != null) { Destroy(m_MembudgetUseT2d); m_MembudgetUseT2d = null; }
        }



        private void Awake()
        {
            m_DrawTxtBackground = Tools.CreateT2D(4, new Color(0, 0, 0, 0.5f));
            m_UnusedT2d = Tools.CreateT2D(4, new Color(0.549f, 0.807f, 0.968f, 0.4f));
            m_UsedT2d = Tools.CreateT2D(4, new Color(0.968f, 0.945f, 0.549f, 0.7f));
            m_OptT2d = Tools.CreateT2D(4, new Color(0.443f, 0.988f, 0.478f, 1f));
            m_AllT2d = Tools.CreateT2D(4, new Color(1, 1, 1, 0.4f));
            m_MembudgetUseT2d = Tools.CreateT2D(4, new Color(0.972f, 0.584f, 0.592f, 0.5f));

            m_MaxDesiredTextureMemory = Texture.desiredTextureMemory;
        }


        private string Num2Percent(float val, string format = "f1") { return (val * 100).ToString(format) + "%"; }

        private float MembudgetUseRatio() { return Texture.desiredTextureMemory / (QualitySettings.streamingMipmapsMemoryBudget * 1024 * 1024); }

        private string BudgetUseRatio(float ratio)
        {
            string s = Num2Percent(ratio);
            return (ratio > 0.85f) ? s + " (使用率较高，需增加内存预算)" : s;  
        }

        private ulong MemSavingNum() { return Texture.totalTextureMemory - Texture.desiredTextureMemory; }

        private float MemSavingPercent(){ return (float)MemSavingNum() / Texture.totalTextureMemory;  }

        private string MemSaving(float percent)  { return Tools.Bytes2Str(MemSavingNum()) + " ( " + Num2Percent(percent) + " ) "; }

        private float NonStreamingTexturePercent() { return (float)Texture.nonStreamingTextureMemory / Texture.totalTextureMemory; }

        private float StreamingTexturePercent() {  return 1 - NonStreamingTexturePercent();  }



        string m_info =
            "<color=#c5c5c5>" +
            "<color=#c59bd1>纹理流数据统计信息（Graphi）</color> \n\n" +
            "系统或平台是否支持纹理流: {0}\n" +
            "激活状态: {1}\n" +
            "\n" +
            "内存预算（MB）: {2}\n" +
            "最低Mip等级: {3}\n" +
            "\n" +
            "实际加载纹理的内存: {4}\n" +
            "实际加载纹理的内存（最高）: {5}\n" +
            "包含纹理流及未使用纹理流的内存: {6}\n" +
            "未使用纹理流的纹理内存: {7}\n" +
            "纹理使用的总内存（全部使用Mip0时）: {8}\n" +
            "\n" +
            "未使用纹理流的占比: {9}\n" +
            "纹理流占比: {10}\n" +
            "内存预算利用率: {11}\n" +
            "内存节省: {12}" +
            "</color>";



        string[] C_Colors = new string[]
        {
                "95f8ae", // 提醒
                "f8f495", // 主关注数据
                "95d4f8", // 次关注数据
                "f89597" // 重要百分比数据
        };
        private string SpecialColor(object o, string c)
        {
            return "<color=#" + c + ">" + o + "</color>";
        }


        private void Update()
        {
            if (Texture.desiredTextureMemory > m_MaxDesiredTextureMemory)
                m_MaxDesiredTextureMemory = Texture.desiredTextureMemory;
        }


        private void OnGUI()
        {
            if (!DrawFlag) { return; }

            if (m_DrawStyle == null)
                m_DrawStyle = new GUIStyle() { richText = true, fontSize = C_DrawSize };


            // 更新尺寸
            Tools.CaluResolutionScale(ref m_LastResolution, C_Size4K, (scale) => 
            {
                m_DrawStyle.fontSize = (int)(C_DrawSize * scale);
                Vector2 size = C_TxtBgSize * scale;
                m_TxtBgRect.Set(0, 0, size.x, size.y);
                size = C_HistogramSize * scale;
                m_HistRect.Set(0, (C_TxtBgSize.y - C_HistogramSize.y -20) * scale, size.x, size.y);
            });

            // 绘制背景
            GUI.DrawTexture(m_TxtBgRect, m_DrawTxtBackground);

            // 绘制数据信息
            float nonStreamingPercent = NonStreamingTexturePercent();
            float streamingPercent = StreamingTexturePercent();
            float memSavingPercent = MemSavingPercent();
            float membudgetUseRatio = MembudgetUseRatio();
            GUILayout.Label
            (
                string.Format
                (m_info,

                    //数据
                    SystemInfo.supportsMipStreaming,
                    SpecialColor(QualitySettings.streamingMipmapsActive, C_Colors[0]),

                    SpecialColor(QualitySettings.streamingMipmapsMemoryBudget, C_Colors[1]),
                    SpecialColor(QualitySettings.streamingMipmapsMaxLevelReduction, C_Colors[1]),

                    SpecialColor(Tools.Bytes2Str(Texture.desiredTextureMemory), C_Colors[1]),
                    Tools.Bytes2Str(m_MaxDesiredTextureMemory),
                    Tools.Bytes2Str(Texture.targetTextureMemory),
                    SpecialColor(Tools.Bytes2Str(Texture.nonStreamingTextureMemory), C_Colors[2]),
                    Tools.Bytes2Str(Texture.totalTextureMemory),

                    SpecialColor(Num2Percent(nonStreamingPercent), C_Colors[2]),
                    SpecialColor(Num2Percent(streamingPercent), C_Colors[1]),
                    SpecialColor(BudgetUseRatio(membudgetUseRatio), C_Colors[3]),
                    SpecialColor(MemSaving(memSavingPercent), (memSavingPercent<=0) ? C_Colors[3] : C_Colors[0])
                ),
                m_DrawStyle
            );


            #region 绘制直观图
            GUILayout.Label("\n\n<color=#c59bd1>直观图</color>", m_DrawStyle);
            // 绘制未使用纹理流、纹理流、以及节省的内存信息直观图
            float whalf = m_HistRect.width * 0.5f;
            Rect r = new Rect(whalf, m_HistRect.y, whalf, m_HistRect.height * streamingPercent);
            GUI.DrawTexture(r, m_UsedT2d);
            r.Set(whalf, m_HistRect.y + m_HistRect.height * streamingPercent, whalf, m_HistRect.height * nonStreamingPercent);
            GUI.DrawTexture(r, m_UnusedT2d);
            r.Set(whalf, m_HistRect.y, whalf, m_HistRect.height * memSavingPercent);
            GUI.DrawTexture(r, m_OptT2d);
            // 绘制内存预算使用率
            r.Set(0, m_HistRect.y, whalf, m_HistRect.height);
            GUI.DrawTexture(r, m_AllT2d);
            r.Set(0, m_HistRect.y, whalf, m_HistRect.height * ((membudgetUseRatio >= 1) ? 1 : membudgetUseRatio));
            GUI.DrawTexture(r, m_MembudgetUseT2d);
            #endregion
        }
    }

}
