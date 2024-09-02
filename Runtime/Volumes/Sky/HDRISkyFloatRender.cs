using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ����ת���Զ�����պ���Ⱦ��
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class HDRISkyFloatRender : SkyRenderer
    {
        //����
        Material m_SkyMat;
        //���Ը�����
        MaterialPropertyBlock m_PropertyBlock = new MaterialPropertyBlock();

        //���¶�ӦShader�ű��е�Passͨ��ID
        static int m_RenderSkyCubemap = 0; // �決��������յ�����ͼ��������չ��գ�
        static int m_RenderSky = 1; // ��Ⱦ��պ�

        //��Ҫ��Shader�ļ���͸��������
        public static readonly int S_HDRICubemap = Shader.PropertyToID("_HDRICubemap");
        public static readonly int S_SkyParam = Shader.PropertyToID("_SkyParam");
        public static readonly int S_PixelCoordToViewDirWS = Shader.PropertyToID("_PixelCoordToViewDirWS");

        //�ڿ�������Զ���תʱ���ڼ�����ת�Ƕȵı���
        float m_AutoRotation = 0;


        /// <summary>
        /// ��������ʼ��
        /// </summary>
        /// <exception cref="System.NotImplementedException"></exception>
        public override void Build()
        {
            //��������
            m_SkyMat = CoreUtils.CreateEngineMaterial(ShaderFind.Get(0, ShaderFind.E_GraInclude.Sky));
        }


        /// <summary>
        /// ����
        /// </summary>
        /// <exception cref="System.NotImplementedException"></exception>
        public override void Cleanup()
        {
            CoreUtils.Destroy(m_SkyMat);
        }


        /// <summary>
        /// ÿ֡����һ�δ˺����������Ҫ�������û�����ĸ���Ƶ�ʽ��е�������ʵ�ִ˺���������� SkySettings UpdateMode����
        /// </summary>
        /// <returns>���ͨ������ȷ������Ҫ������Ⱦ��չ��գ��򷵻� true�����򷵻� false��</returns>
        protected override bool Update(BuiltinSkyParameters builtinParams)
        {
            //����

            return false;
        }


        /// <summary>
        /// ��Ⱦ 
        /// </summary>
        /// <param name="builtinParams">��Ⱦ��յ��������</param>
        /// <param name="renderForCubemap">���Ҫ�������Ⱦ����������ͼ�����ڹ��գ����� true������������£������Ⱦ����Ҫ����ʵ�֣���˺�����</param>
        /// <param name="renderSunDisk">��������Ⱦ��֧����Ⱦ̫��Բ�̣��ڴ˲�������Ϊ false ʱ��������Ⱦ̫��Բ�̡�</param>
        /// <exception cref="System.NotImplementedException"></exception>
        public override void RenderSky(BuiltinSkyParameters builtinParams, bool renderForCubemap, bool renderSunDisk)
        {
            using (new ProfilingScope(builtinParams.commandBuffer, new ProfilingSampler("Draw Graphi-HDRI SkyFloat")))
            {
                //ѡȡ��ȾPassͨ��
                int passID = renderForCubemap ? m_RenderSkyCubemap : m_RenderSky;

                //��ȡ�Զ�����յ�����
                HDRISkyFloatSettings skyset = builtinParams.skySettings as HDRISkyFloatSettings;

                //��ȡ�ع��
                float intensity = GetSkyIntensity(skyset, builtinParams.debugSettings);

                //���������ת�Ƕ�
                if (skyset.m_AutoRotation.value)
                {
                    m_AutoRotation += skyset.m_AutoRotationSpeed.value;
                    m_AutoRotation = (m_AutoRotation > 360) ? 0 : m_AutoRotation;
                    skyset.rotation.value = m_AutoRotation;
                }
                float phi = -Mathf.Deg2Rad * skyset.rotation.value; //ת����

                //��Shader�ļ��ṩ����
                m_PropertyBlock.SetTexture(S_HDRICubemap, skyset.m_HDRICubemap.value);
                m_PropertyBlock.SetVector(S_SkyParam, new Vector4(intensity, 0.0f, Mathf.Cos(phi), Mathf.Sin(phi)));
                m_PropertyBlock.SetMatrix(S_PixelCoordToViewDirWS, builtinParams.pixelCoordToViewDirMatrix);

                //����ָ��壬���ʣ��������ԣ�ѡ�õ�Passͨ��
                CoreUtils.DrawFullScreen(builtinParams.commandBuffer, m_SkyMat, m_PropertyBlock, passID);
            }
        }
    }

}