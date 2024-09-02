using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
#if UNITY_EDITOR
using UnityEditor.Rendering.HighDefinition;
using UnityEditor;
#endif
using System;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// Bloom
    /// 
    /// <para>
    ///     实现的效果与传统方式的效果一致，但并不是以后处理volume形式挂载。<br></br>
    ///     触发方式是由自定义全屏渲染通道执行。好处是在渲染管线中，可对其进行不同的节点插入，要比传统的volume执行更为自由。<br></br>
    ///     因此，在HDRP中将Bloom效果移至到自定义渲染通道中实现并执行。
    /// </para>
    /// 
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    public class Bloom : CustomPass
    {
        [Space(10)]
        #region 对外参数
        //[ColorUsageAttribute(true,true)]
        public Color m_Color = Color.white; // 颜色
        public float m_Intensity = 0; // 强度
        [Range(0, 1)]
        public float m_Threshold = 0.2f; // 阔值（亮度阔值）
        [Range(0, 1)]
        public float m_Spread = 0.4f; // 光散 
        [Range(1, 16)]
        public int m_Interation = 2; // 迭代次数
        #endregion


        Shader m_shader;
        Material m_mat;

        const int MAX_MIP_INTER = 16;
        RTHandle[] m_mipDown;
        RTHandle[] m_mipUp;
        float[] m_scales;
        Vector4 _params = Vector4.zero;
        RTHandle m_combine;



        public Bloom() { name = "Graphi_FullScreen_Bloom"; }


        protected override bool executeInSceneView => false;


        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            m_shader = ShaderFind.Get(1, ShaderFind.E_GraInclude.FullScreen);
            m_mat = CoreUtils.CreateEngineMaterial(m_shader);

            // 创建纹理
            m_mipDown = new RTHandle[MAX_MIP_INTER];
            m_mipUp = new RTHandle[MAX_MIP_INTER];
            m_scales = new float[MAX_MIP_INTER];
            float scal = 1.0f;
            for (int i = 0; i < MAX_MIP_INTER; i++)
            {
                scal *= 0.5f;
                m_scales[i] = 1 / scal;
                m_mipDown[i] = CreateTempRTHandle("Graphi Bloom MipDown" + i, scal);
                m_mipUp[i] = CreateTempRTHandle("Graphi Bloom MipUp" + i, scal);
            }
            m_combine = CreateTempRTHandle("Graphi Bloom Combine");
        }


        RTHandle CreateTempRTHandle(string name, float factor = 1.0f)
        {
            return RTHandles.Alloc
            (
                Vector2.one * factor,
                TextureXR.slices,
                dimension: TextureXR.dimension,
                useDynamicScale: true,
                colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
                name: name
            );
        }


        void SetTarget(CustomPassContext ctx, RTHandle tar)
        {
            CoreUtils.SetRenderTarget(ctx.cmd, tar, ClearFlag.None);
        }

        void DrawFS(CustomPassContext ctx, int id)
        {
            CoreUtils.DrawFullScreen(ctx.cmd, m_mat, ctx.propertyBlock, shaderPassId: id);
        }


        protected override void Execute(CustomPassContext ctx)
        {
            // step1: 提取亮度
            _params.Set(m_scales[0], m_Threshold, 0, 0);
            ctx.propertyBlock.SetVector("_Params", _params);
            ctx.propertyBlock.SetTexture("_Tex", ctx.cameraColorBuffer);
            SetTarget(ctx, m_mipDown[0]);
            DrawFS(ctx, 0);

            // step2：降采样（高斯模糊）
            RTHandle lastRT = m_mipDown[0];
            for (int i = 1; i < m_Interation; i++)
            {
                _params.Set(m_scales[i], 0, 0, 0);

                // 横向
                ctx.propertyBlock.SetVector("_Params", _params);
                ctx.propertyBlock.SetTexture("_Tex", lastRT);
                SetTarget(ctx, m_mipUp[i]);
                DrawFS(ctx, 1);

                // 纵向
                ctx.propertyBlock.SetVector("_Params", _params);
                ctx.propertyBlock.SetTexture("_Tex", m_mipUp[i]);
                SetTarget(ctx, m_mipDown[i]);
                DrawFS(ctx, 2);

                lastRT = m_mipDown[i];
            }

            // step3：升采样（双线性）
            for (int i = m_Interation - 2; i >= 0; i--)
            {
                RTHandle lowmip = (i == m_Interation - 2) ? m_mipDown[i + 1] : m_mipUp[i + 1];
                RTHandle highmip = m_mipDown[i];
                RTHandle dst = m_mipUp[i];

                _params.Set(m_scales[i], m_Spread, 0, 0);
                ctx.propertyBlock.SetVector("_Params", _params);
                ctx.propertyBlock.SetTexture("_Tex", highmip);
                ctx.propertyBlock.SetTexture("_LowTex", lowmip);
                SetTarget(ctx, dst);
                DrawFS(ctx, 3);
            }

            // step4：合成
            Color c = m_Color.linear;
            float luminance = ColorUtils.Luminance(c);
            c = (luminance > 0f) ? c * (1f / luminance) : Color.white;

            _params.Set(c.r, c.g, c.b, m_Intensity);
            ctx.propertyBlock.SetVector("_Params", _params);
            ctx.propertyBlock.SetTexture("_Tex", ctx.cameraColorBuffer);
            ctx.propertyBlock.SetTexture("_LowTex", m_mipUp[0]);
            SetTarget(ctx, m_combine);
            DrawFS(ctx, 4);

            CustomPassUtils.Copy(ctx, m_combine, ctx.cameraColorBuffer);
        }

        protected override void Cleanup()
        {
            CoreUtils.Destroy(m_mat);
            for (int i = 0; i < MAX_MIP_INTER; i++)
            {
                m_mipDown[i]?.Release();
                m_mipUp[i]?.Release();
            }
            m_combine?.Release();
            _params.Set(0, 0, 0, 0);
        }
    }


#if UNITY_EDITOR
    /// <summary>
    /// 扩展 Inspector 操作面板（ Bloom泛光 ）
    /// <para>作者：强辰</para>
    /// </summary>
    [CustomPassDrawerAttribute(typeof(Bloom))]
    public class BloomCustomPassDrawer : CustomPassDrawer
    {
        SerializedProperty prop_color;
        SerializedProperty prop_intensity;
        SerializedProperty prop_threshold;
        SerializedProperty prop_spread;
        SerializedProperty prop_interation;

        protected override void Initialize(SerializedProperty customPass)
        {
            prop_color      = customPass.FindPropertyRelative("m_Color");
            prop_intensity  = customPass.FindPropertyRelative("m_Intensity");
            prop_threshold  = customPass.FindPropertyRelative("m_Threshold");
            prop_spread     = customPass.FindPropertyRelative("m_Spread");
            prop_interation = customPass.FindPropertyRelative("m_Interation");
        }

        protected override void DoPassGUI(SerializedProperty customPass, Rect rect)
        {
            EditorGUI.PropertyField(rect, prop_color, new GUIContent("颜色"), true);
            rect.y += GetH(prop_color);
            EditorGUI.PropertyField(rect, prop_intensity, new GUIContent("强度"), true);
            rect.y += GetH(prop_intensity);
            EditorGUI.PropertyField(rect, prop_threshold, new GUIContent("亮度阔值"), true);
            rect.y += GetH(prop_threshold);
            EditorGUI.PropertyField(rect, prop_spread, new GUIContent("辉光扩散"), true);
            rect.y += GetH(prop_spread);
            EditorGUI.PropertyField(rect, prop_interation, new GUIContent("迭代次数"), true);
            rect.y += GetH(prop_interation, 10);

        }


        /// <summary>
        /// 在Inspector中，每个自定义属性项的行高
        /// </summary>
        /// <param name="p"></param>
        /// <param name="adddist"></param>
        /// <returns></returns>
        private float GetH(SerializedProperty p, float adddist = 0.0f)
        {
            return EditorGUI.GetPropertyHeight(p) + EditorGUIUtility.standardVerticalSpacing + adddist;
        }


        /// <summary>
        /// Inspector 总高度
        /// </summary>
        /// <param name="customPass"></param>
        /// <returns></returns>
        protected override float GetPassHeight(SerializedProperty customPass)
        {
            return base.GetPassHeight(customPass) + 10;
        }


        /// <summary>
        /// 屏蔽unity提供的默认标签，在辉光渲染过程中，无需修改默认提供的标签项
        /// </summary>
        protected override PassUIFlag commonPassUIFlags => PassUIFlag.None;

    }
#endif
}