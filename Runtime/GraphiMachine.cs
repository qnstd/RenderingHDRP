using System;
using System.Collections.ObjectModel;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// HDRP 渲染管理器
    /// <para>作者：强辰</para>
    /// </summary>
    public class GraphiMachine : MonoBehaviour
    {
        /// <summary>
        /// 启动时自动初始化
        /// </summary>
        [RuntimeInitializeOnLoadMethod]
        static private void Initialize()
        {
            bool ok = true;

            // 创建自身
            GameObject self = new GameObject("GraphiMachine");
            self.AddComponent<GraphiMachine>();
            GameObject.DontDestroyOnLoad(self);

            // 开启SRP
            GraphicsSettings.useScriptableRenderPipelineBatching = true;
            // 默认开启纹理流丢去未使用的mips
            TextureDiscardUnusedMips(true);

            // 设置垂直同步、帧率
#if UNITY_EDITOR
            Application.targetFrameRate = FrameRate;
#else
            VSync(1);
#endif

            // 创建热扭曲渲染通道
            GameObject twistVolume = CreateDrawRendererCustomPassTwist();
            bool single = twistVolume != null;
            if (single) { GameObject.DontDestroyOnLoad(twistVolume); }
            ok &= single;

            // 输出初始化结果
            string info = string.Format("Graphi Library 初始化: {0}", ((ok) ? "成功" : "失败"));
            if (ok) { Lg.Trace(info); }
            else { Lg.Err(info); }
        }



        #region 常量
        /// <summary>
        /// Graphi 渲染库内置层级
        /// </summary>
        static public string[] C_BuildinLayer = new string[]
        {
        // ※※※ 以下注册的顺序不能改变 ※※※

            "Graphi_DrawRendererCP_Twist", //热扭曲特定渲染层
            "Edges",    // 用于游戏对象在全屏通道描边时所使用的层级
            "OccDisplay", // 用于被遮挡物（非半透明）显示剪影的层级
        };
        #endregion


        #region Mono
        private void Update()
        {
            Kb.Run();
        }
        #endregion



        #region 静态公共接口

        #region 体积
        /// <summary>
        /// 创建热扭曲渲染通道
        /// <para>在游戏生命周期下，只需创建一次体积组件即可。</para>
        /// </summary>
        /// <returns>创建成功则返回渲染通道的Volume对象，否则为空</returns>
        static public GameObject CreateDrawRendererCustomPassTwist()
        {
            string layer = C_BuildinLayer[0];
            int layid = 1 << LayerMask.NameToLayer(layer);
            if (layid < 0)
            {
                Lg.Err("无法创建热扭曲渲染通道！渲染特定层不存在。");
                return null;
            }

            if (GameObject.Find(layer) != null)
            {
                Lg.Err("场景中已存在热扭曲渲染通道，无法进行创建！请注意，若场景中存在的热扭曲渲染通道是在Editor模式下手动创建的，请及时删除，运行时会自动创建。");
                return null;
            }

            //创建自定义渲染通道Volume
            GameObject go = new GameObject(layer);
            CustomPassVolume cpv = go.AddComponent<CustomPassVolume>();
            cpv.injectionPoint = CustomPassInjectionPoint.BeforePostProcess;
            cpv.isGlobal = true;

            //创建自定义渲染并修改参数
            CustomPass cp = CustomPass.CreateDrawRenderersPass(
                CustomPass.RenderQueueType.LowTransparent,
                layid,
                overrideMaterial: null,
                sorting: UnityEngine.Rendering.SortingCriteria.CommonTransparent | UnityEngine.Rendering.SortingCriteria.CommonOpaque,
                targetColorBuffer: CustomPass.TargetBuffer.Camera,
                targetDepthBuffer: CustomPass.TargetBuffer.Camera,
                clearFlags: UnityEngine.Rendering.ClearFlag.None
                );
            cp.name = layer;

            DrawRenderersCustomPass drcp = (DrawRenderersCustomPass)cp;
            drcp.overrideMode = DrawRenderersCustomPass.OverrideMaterialMode.None;
            drcp.overrideDepthState = true;
            drcp.depthWrite = false;

            //添加
            cpv.customPasses.Add(drcp);
            return go;
        }


        /// <summary>
        /// 创建遮挡显示组件
        /// <para>在游戏生命周期下，只需创建一次体积组件即可。</para>
        /// </summary>
        /// <param name="depthMaterial">绘制遮挡层对象深度的材质</param>
        /// <param name="drawMaterial">绘制遮挡对象效果的材质</param>
        /// <returns></returns>
        static public GameObject CreateOccDisplayDrawCustomPass(Material depthMaterial, Material drawMaterial)
        {
            string layer = C_BuildinLayer[2];
            int layid = 1 << LayerMask.NameToLayer(layer);
            if (layid < 0)
            {
                Debug.LogError("无法创建遮挡显示组件！渲染特定层不存在。");
                return null;
            }
            if (GameObject.Find(layer) != null)
            {
                Debug.LogError("场景中已存在遮挡显示组件，无法进行创建！");
                return null;
            }

            // 创建体积
            GameObject go = new GameObject(layer);
            CustomPassVolume cpv = go.AddComponent<CustomPassVolume>();
            cpv.injectionPoint = CustomPassInjectionPoint.BeforeTransparent;
            cpv.isGlobal = true;

            // 创建着色第1步需要的渲染通道
            CustomPass cp = CustomPass.CreateDrawRenderersPass
            (
                CustomPass.RenderQueueType.AllOpaque,
                layid,
                null,
                targetColorBuffer: CustomPass.TargetBuffer.Custom,
                targetDepthBuffer: CustomPass.TargetBuffer.Custom,
                clearFlags: ClearFlag.All,
                overrideMaterialPassName: "Draw CustomObject Color And Depth Buffer"
            );
            DrawRenderersCustomPass drcp = (DrawRenderersCustomPass)cp;
            drcp.name = "OccDisplayDrawDepth";
            drcp.overrideMode = DrawRenderersCustomPass.OverrideMaterialMode.Material;
            drcp.overrideMaterial = depthMaterial; // 材质
            drcp.overrideDepthState = false;
            drcp.overrideStencil = false;
            drcp.sortingCriteria = SortingCriteria.CommonOpaque;

            // 创建着色第2步需要的渲染通道
            CustomPass cp2 = CustomPass.CreateFullScreenPass(null);
            FullScreenCustomPass fscp = (FullScreenCustomPass)cp2;
            fscp.name = "OccDisplayDraw";
            fscp.clearFlags = ClearFlag.None;
            fscp.fetchColorBuffer = false;
            fscp.fullscreenPassMaterial = drawMaterial; // 材质

            // 添加
            cpv.customPasses.Add(drcp);
            cpv.customPasses.Add(fscp);
            return go;
        }

        #endregion

        #region 纹理流
        /// <summary>
        /// 设置纹理流是否丢弃未使用的Mips
        /// <para>如果当前系统或者平台不支持纹理流的情况下，忽略此项操作</para>
        /// </summary>
        /// <param name="b">true: 丢弃；false：保留（默认：开启丢弃）</param>
        static public void TextureDiscardUnusedMips(bool b)
        {
            if (SystemInfo.supportsMipStreaming)
                Texture.streamingTextureDiscardUnusedMips = b;
        }

        /// <summary>
        /// 激活纹理流
        /// </summary>
        /// <param name="b"></param>
        static public void TextureStreamingActive(bool b) { QualitySettings.streamingMipmapsActive = b; }
        /// <summary>
        /// 纹理流应用到所有摄像机
        /// </summary>
        /// <param name="b"></param>
        static public void TextureStreamingApplayAllCam(bool b) { QualitySettings.streamingMipmapsAddAllCameras = b; }
        /// <summary>
        /// 纹理流内存预算
        /// </summary>
        /// <param name="m">内存预算值（单位：MB）</param>
        static public void MipMemorybudget(float m) { QualitySettings.streamingMipmapsMemoryBudget = m; }
        /// <summary>
        /// 纹理流最大降低的品质等级
        /// </summary>
        /// <param name="lv"></param>
        static public void MipMaxLvReduction(int lv) { QualitySettings.streamingMipmapsMaxLevelReduction = lv; }
        /// <summary>
        /// 设置纹理流基础信息
        /// </summary>
        /// <param name="b">开启、关闭</param>
        /// <param name="budget">内存预算</param>
        /// <param name="lv">最大降低的品质等级</param>
        static public void TextureStreamingBaseInfo(bool b, float budget, int lv)
        {
            TextureStreamingActive(true);
            MipMemorybudget(budget);
            MipMaxLvReduction(lv);
        }
        #endregion

        #region 品质、效果
        /// <summary>
        /// 当前渲染品质等级
        /// </summary>
        static public int CurrentQualityLevel { get { return QualitySettings.GetQualityLevel(); } }

        /// <summary>
        /// 当前渲染品质名称
        /// </summary>
        static public string CurrentQualityName { get { return GetQualityNameByLevel(CurrentQualityLevel); } }

        /// <summary>
        /// 获取所有注册的渲染品质名称
        /// </summary>
        /// <returns></returns>
        static public string[] AllQualitys { get { return QualitySettings.names; } }

        /// <summary>
        /// 获取参数渲染品质等级对应的渲染品质名称
        /// </summary>
        /// <param name="lv">渲染等级</param>
        /// <returns>不存在则返回null，否则返回对应的名称</returns>
        static public string GetQualityNameByLevel(int lv)
        {
            if (!IsContainLevel(lv))
            {
                Lg.Err("未注册的渲染品质等级！无法完成渲染品质更换。");
                return null;
            }
            return AllQualitys[lv];
        }

        /// <summary>
        /// 获取参数渲染品质名称对应的渲染品质等级
        /// </summary>
        /// <param name="name"></param>
        /// <returns>不存在则返回-1，否则返回0-n。</returns>
        static public int GetLevelByQualityName(string name)
        {
            if (string.IsNullOrEmpty(name)) { return -1; }
            for (int i = 0; i < AllQualitys.Length; i++)
            {
                if (AllQualitys[i] == name)
                {
                    return i;
                }
            }
            return -1;
        }


        /// <summary>
        /// 是否包含参数对应的渲染品质
        /// </summary>
        /// <param name="lv">渲染品质等级</param>
        /// <returns></returns>
        static public bool IsContainLevel(int lv)
        {
            return !(lv < 0 || lv > AllQualitys.Length - 1);
        }

        /// <summary>
        /// 设置渲染品质
        /// </summary>
        /// <param name="lv">品质等级</param>
        /// <param name="isApplayExpensiveChanges">更换渲染品质后，是否对高级设置进行改变（比如抗锯齿等级等）。高级设置切换时比较消耗性能，会造成短暂的卡顿等现象。</param>
        static public void SetQuality(int lv, bool isApplayExpensiveChanges = false)
        {
            //与当前品质相同，返回
            if (lv == CurrentQualityLevel) { return; }

            //Type typ = typeof(QualitySettings);
            //FieldInfo fieldinfo = typ.GetField("s_RenderPipelineAssets", BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Instance);
            //List<RenderPipelineAsset> lst = (List<RenderPipelineAsset>)fieldinfo.GetValue(null);

            //不存在的Level配置
            if (!IsContainLevel(lv))
            {
                Lg.Err("未注册的渲染品质等级！无法完成渲染品质更换。");
                return;
            }

            //设置
            QualitySettings.SetQualityLevel(lv, isApplayExpensiveChanges);
        }


        /// <summary>
        /// 当前平台的屏幕最大刷新率
        /// </summary>
        /// <returns></returns>
        static public int CurrentRefreshRate() { return (int)Mathf.Ceil(Screen.currentResolution.refreshRateRatio.numerator / 1000.0f); }


        /// <summary>
        /// 垂直同步
        /// <para>同时会根据设置的垂直同步数重置当前帧率</para>
        /// </summary>
        /// <param name="val">0：关闭，1-2：开启，每帧之间的垂直同步数。</param>
        static public void VSync(int val)
        {// 官方文档：//https://docs.unity3d.com/2022.3/Documentation/ScriptReference/QualitySettings-vSyncCount.html

            if (val < 0 || val > 2) { return; }

            QualitySettings.vSyncCount = val;
            ResetFrameRate();
        }


        static private int frameRate = 60;
        /// <summary>
        /// 获取当前设置的帧率
        /// </summary>
        static public int FrameRate { get { return frameRate; } }
        /// <summary>
        /// 设置帧率 (不支持VR)
        /// </summary>
        /// <param name="customFrameRate">此参数是针对独立平台（例如：PC，PS，XBOX等）关闭垂直同步状态时设置的帧率。如果为-1，则使用平台支持的最大屏幕刷新率；否则，使用自定义值。</param>
        /// <param name="mobileVSyncCount">在移动端下代替Unity内置的垂直同步数, 可用值为[1-2]</param>
        static public void ResetFrameRate(int customFrameRate = -1, int mobileVSyncCount = 1)
        { // 官方文档：https://docs.unity.cn/cn/2020.3/ScriptReference/Application-targetFrameRate.html

            int defaultMaxRefreshRate = CurrentRefreshRate();

            if (Application.isMobilePlatform)
            {// 移动平台（iOS平台特殊，不使用unity提供的垂直同步，所以这里以 [当前设备的屏幕最大刷新率 / 自定义整数] 进行帧率设置，保证移动平台的统一性）
                mobileVSyncCount = (mobileVSyncCount < 1 || mobileVSyncCount > 2) ? 1 : mobileVSyncCount;
                frameRate = defaultMaxRefreshRate / mobileVSyncCount;
                Application.targetFrameRate = frameRate;
            }
            else
            {// 各个独立平台（PC、PS、XBOX等）
                int vSyncCount = QualitySettings.vSyncCount;
                if (vSyncCount == 0)
                {// 关闭垂直同步，直接设置为当前平台可支持的最大屏幕刷新率
                    frameRate = (customFrameRate == -1) ? defaultMaxRefreshRate : customFrameRate;
                    Application.targetFrameRate = frameRate;
                }
                else
                {// 开启垂直同步，帧率 = 所在平台的默认刷新率 / 每帧之间的垂直同步数（此时，Unity会忽略 TargetFrameRate 参数值）
                    frameRate = defaultMaxRefreshRate / vSyncCount;
#if UNITY_EDITOR
                    // 编辑器内使用垂直同步时，帧率还是会保持平台最大屏幕刷新率计算。因此，在这里需要强制改变帧率。发布后无需改变，unity会自动使用垂直同步设置的值。
                    Application.targetFrameRate = frameRate;
#endif
                }
            }
        }

        /// <summary>
        /// 全局纹理质量级别
        /// <para>只影响2D和2D纹理数组，对其他纹理、虚拟纹理及Unity编辑器使用的内置纹理则无效。如果对其他纹理使用，则以纹理流形式控制</para>
        /// <para>如果发生改变，Unity会需要额外的帧重新上传被影响的纹理</para>
        /// </summary>
        /// <param name="val">质量级别，值范围[0-3](值越大，意味着GPU使用更少的内存和更少的处理时间，显示效果也会更模糊。如果渲染器的材质没有使用任何贴图，则以全分辨率渲染。</param>
        static public void TextureQualityLevel(int val)
        {
            if (val < 0 || val > 3) { return; }
            if (QualitySettings.globalTextureMipmapLimit == val) { return; }
            QualitySettings.globalTextureMipmapLimit = val;
        }


        /// <summary>
        /// 设置摄像机的自定义帧渲染项
        /// </summary>
        /// <param name="field">自定义帧渲染项</param>
        /// <param name="flag">true：开启，false：关闭</param>
        /// <param name="cam">摄像机（默认：null，自动获取标记为Main Camera的摄像机对象）</param>
        static public void CamCustomFrameSettings(FrameSettingsField field, bool flag, Camera cam = null)
        {
            // 若参数传进的是空，则获取场景中被标记的主相机
            if (cam == null)
                cam = Camera.main;

            // cam最终值被确定后，再次判断是否为空。若为空则返回。
            if (cam == null) { return; }

            HDAdditionalCameraData hdCameraData = cam.GetComponent<HDAdditionalCameraData>();
            if (hdCameraData == null) { return; }

            // 允许运行时动态修改自定义渲染配置
            hdCameraData.customRenderingSettings |= true;

            // 修改配置项
            hdCameraData.renderingPathCustomFrameSettingsOverrideMask.mask[(uint)field] = !flag; // 开启覆盖项
            hdCameraData.renderingPathCustomFrameSettings.SetEnabled(field, flag); // 设置具体的值

        }


        /// <summary>
        /// 设置光源的投影分辨率质量
        /// </summary>
        /// <param name="light">光源</param>
        /// <param name="resolution">分辨率（尺寸必须是2的幂）</param>
        static public void LightShadowResolution(Light light, int resolution)
        {
            if (light == null) { return; }
            HDAdditionalLightData lightData = light.GetComponent<HDAdditionalLightData>();
            if (lightData == null) { return; }

            if (!Mth.IntIsApowof2(resolution))
            {
                Lg.Err("设置光源投影质量错误！投影质量的分辨率值不是2的幂。");
                return;
            }

            lightData.SetShadowResolutionOverride(true);
            lightData.SetShadowResolution(resolution);
        }


        /// <summary>
        /// 设置体积Volume中某个组件下的参数
        /// </summary>
        /// <typeparam name="T">体积组件中某一后处理组件类型</typeparam>
        /// <param name="vol">体积组件</param>
        /// <param name="index">体积组件中某一后处理效果组件要修改其参数的索引</param>
        /// <param name="vp">参数对应的值</param>
        static public void SetVolumeComParameter<T>(Volume vol, int index, VolumeParameter vp) where T : VolumeComponent
        {
            if (vol == null) { return; } // 体积组件为空

            VolumeProfile vProfile = vol.profile; // 不存在体积配置
            if (vProfile == null) { return; }

            if (!vProfile.Has<T>()) { return; } // 不存在体积项

            // 修改参数
            vProfile.TryGet<T>(out T com);
            ReadOnlyCollection<VolumeParameter> parameters = com.parameters;
            if (index < 0 || index > parameters.Count - 1) { return; } // 索引不合法，不在范围内

            VolumeParameter vParameter = parameters[index];
            if (vParameter.GetType() != vp.GetType()) { return; } // 参数的值类型与要修改的值类型不匹配

            try
            {
                vParameter.overrideState = true;
                vParameter.SetValue(vp);

            }
            catch (Exception e) { Lg.Err(e.Message); }
        }
        #endregion

        #region 系统信息
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

        #endregion
    }
}