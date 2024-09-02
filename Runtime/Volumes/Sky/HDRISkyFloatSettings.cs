using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ����ת����պ�������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    [VolumeComponentMenu("Sky/HDRI SkyFloat")]
    [SkyUniqueID(SKY_UNIQUE_ID)]
    public class HDRISkyFloatSettings : SkySettings
    {
        /// <summary>
        /// ��պ�ΨһID
        /// <para>���Բ鿴Unity������ע�����պ����� <see cref="SkyType"/></para>
        /// </summary>
        const int SKY_UNIQUE_ID = 20230323;


        #region �������
        [Header("HDRI ����ͼ")]
        public CubemapParameter m_HDRICubemap = new CubemapParameter(null);
        [Header("����Զ���ת��������ʱ��Ĭ�ϵ�Rotation���������ϳ���")]
        public BoolParameter m_AutoRotation = new BoolParameter(true);
        [Header("����Զ���ת�ٶȣ�ֻ�ڿ����Զ���תʱ���ã�")]
        public FloatParameter m_AutoRotationSpeed = new FloatParameter(0.01f);
        #endregion



        /// <summary>
        /// ����ʵ�ʵ������Ⱦ�ű�����
        /// </summary>
        /// <returns></returns>
        public override Type GetSkyRendererType()
        {
            return typeof(HDRISkyFloatRender);
        }


        /// <summary>
        /// ȷ����ն��䷴�������ͼˢ�µ�ʱ��
        /// </summary>
        /// <returns></returns>
        public override int GetHashCode()
        {
            int hash = base.GetHashCode();
            unchecked
            {//�����������������ʱ�ı����쳣��ֱ�ӷ�������ĸ�λ��
                hash = hash * 23 + m_HDRICubemap.GetHashCode();
                hash = hash * 23 + m_AutoRotation.GetHashCode();
                hash = hash * 23 + m_AutoRotationSpeed.GetHashCode();
            }
            return hash;
        }

        public override int GetHashCode(Camera camera)
        {
            //�����������Է����仯�������Hash����ȷ���Ƿ������յķ�������ͼ����
            return GetHashCode();
        }
    }
}