using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 带旋转的自定义天空盒渲染器
    /// <para>作者：强辰</para>
    /// </summary>
    public class HDRISkyFloatRender : SkyRenderer
    {
        //材质
        Material m_SkyMat;
        //属性更新器
        MaterialPropertyBlock m_PropertyBlock = new MaterialPropertyBlock();

        //以下对应Shader脚本中的Pass通道ID
        static int m_RenderSkyCubemap = 0; // 烘焙，绘制天空的立方图（用于天空光照）
        static int m_RenderSky = 1; // 渲染天空盒

        //需要给Shader文件中透传的属性
        public static readonly int S_HDRICubemap = Shader.PropertyToID("_HDRICubemap");
        public static readonly int S_SkyParam = Shader.PropertyToID("_SkyParam");
        public static readonly int S_PixelCoordToViewDirWS = Shader.PropertyToID("_PixelCoordToViewDirWS");

        //在开启天空自动旋转时用于计算旋转角度的变量
        float m_AutoRotation = 0;


        /// <summary>
        /// 构建，初始化
        /// </summary>
        /// <exception cref="System.NotImplementedException"></exception>
        public override void Build()
        {
            //创建材质
            m_SkyMat = CoreUtils.CreateEngineMaterial(ShaderFind.Get(0, ShaderFind.E_GraInclude.Sky));
        }


        /// <summary>
        /// 清理
        /// </summary>
        /// <exception cref="System.NotImplementedException"></exception>
        public override void Cleanup()
        {
            CoreUtils.Destroy(m_SkyMat);
        }


        /// <summary>
        /// 每帧调用一次此函数。如果需要独立于用户定义的更新频率进行迭代，则实现此函数（请参阅 SkySettings UpdateMode）。
        /// </summary>
        /// <returns>如果通过更新确定了需要重新渲染天空光照，则返回 true。否则返回 false。</returns>
        protected override bool Update(BuiltinSkyParameters builtinParams)
        {
            //待定

            return false;
        }


        /// <summary>
        /// 渲染 
        /// </summary>
        /// <param name="builtinParams">渲染天空的引擎参数</param>
        /// <param name="renderForCubemap">如果要将天空渲染到立方体贴图以用于光照，传入 true。在这种情况下，天空渲染器需要其他实现，因此很有用</param>
        /// <param name="renderSunDisk">如果天空渲染器支持渲染太阳圆盘，在此参数设置为 false 时，不会渲染太阳圆盘。</param>
        /// <exception cref="System.NotImplementedException"></exception>
        public override void RenderSky(BuiltinSkyParameters builtinParams, bool renderForCubemap, bool renderSunDisk)
        {
            using (new ProfilingScope(builtinParams.commandBuffer, new ProfilingSampler("Draw Graphi-HDRI SkyFloat")))
            {
                //选取渲染Pass通道
                int passID = renderForCubemap ? m_RenderSkyCubemap : m_RenderSky;

                //获取自定义天空的配置
                HDRISkyFloatSettings skyset = builtinParams.skySettings as HDRISkyFloatSettings;

                //获取曝光度
                float intensity = GetSkyIntensity(skyset, builtinParams.debugSettings);

                //设置天空旋转角度
                if (skyset.m_AutoRotation.value)
                {
                    m_AutoRotation += skyset.m_AutoRotationSpeed.value;
                    m_AutoRotation = (m_AutoRotation > 360) ? 0 : m_AutoRotation;
                    skyset.rotation.value = m_AutoRotation;
                }
                float phi = -Mathf.Deg2Rad * skyset.rotation.value; //转弧度

                //向Shader文件提供参数
                m_PropertyBlock.SetTexture(S_HDRICubemap, skyset.m_HDRICubemap.value);
                m_PropertyBlock.SetVector(S_SkyParam, new Vector4(intensity, 0.0f, Mathf.Cos(phi), Mathf.Sin(phi)));
                m_PropertyBlock.SetMatrix(S_PixelCoordToViewDirWS, builtinParams.pixelCoordToViewDirMatrix);

                //绘制指令缓冲，材质，材质属性，选用的Pass通道
                CoreUtils.DrawFullScreen(builtinParams.commandBuffer, m_SkyMat, m_PropertyBlock, passID);
            }
        }
    }

}