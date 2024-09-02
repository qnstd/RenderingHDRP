using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 带旋转的天空盒配置项
    /// <para>作者：强辰</para>
    /// </summary>
    [VolumeComponentMenu("Sky/HDRI SkyFloat")]
    [SkyUniqueID(SKY_UNIQUE_ID)]
    public class HDRISkyFloatSettings : SkySettings
    {
        /// <summary>
        /// 天空盒唯一ID
        /// <para>可以查看Unity内置已注册的天空盒类型 <see cref="SkyType"/></para>
        /// </summary>
        const int SKY_UNIQUE_ID = 20230323;


        #region 对外参数
        [Header("HDRI 立方图")]
        public CubemapParameter m_HDRICubemap = new CubemapParameter(null);
        [Header("天空自动旋转（当开启时，默认的Rotation参数将被废除）")]
        public BoolParameter m_AutoRotation = new BoolParameter(true);
        [Header("天空自动旋转速度（只在开启自动旋转时可用）")]
        public FloatParameter m_AutoRotationSpeed = new FloatParameter(0.01f);
        #endregion



        /// <summary>
        /// 返回实际的天空渲染脚本类型
        /// </summary>
        /// <returns></returns>
        public override Type GetSkyRendererType()
        {
            return typeof(HDRISkyFloatRender);
        }


        /// <summary>
        /// 确定天空对其反射的立方图刷新的时间
        /// </summary>
        /// <returns></returns>
        public override int GetHashCode()
        {
            int hash = base.GetHashCode();
            unchecked
            {//不检查因计算整数溢出时的编译异常，直接放弃溢出的高位。
                hash = hash * 23 + m_HDRICubemap.GetHashCode();
                hash = hash * 23 + m_AutoRotation.GetHashCode();
                hash = hash * 23 + m_AutoRotationSpeed.GetHashCode();
            }
            return hash;
        }

        public override int GetHashCode(Camera camera)
        {
            //如果摄像机属性发生变化，则计算Hash，并确定是否进行天空的反射立方图更新
            return GetHashCode();
        }
    }
}