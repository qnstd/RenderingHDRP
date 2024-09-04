using UnityEditor;
using UnityEditor.Rendering.HighDefinition;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 径向模糊
    /// <para>作者：强辰</para>
    /// </summary>
    public class RadialBlur : CustomPass
    {
        /// <summary>
        /// 降采样尺寸枚举
        /// </summary>
        public enum DownsampleEnum
        {
            x1 = 1,
            x2 = 2,
            x4 = 4,
            x8 = 8
        }


        #region 对外属性
        public DownsampleEnum m_Downsample = DownsampleEnum.x2;
        public Vector2 m_Center = new Vector2(0.25f, 0.25f);
        [Range(2, 64)] public int m_Internation = 8;
        public float m_Intensity = 0.6f;
        #endregion


        #region 变量
        Shader m_Shader;
        Material m_Material;

        RTHandle m_DownsampleResult;
        RTHandle m_DownsampleTex;
        DownsampleEnum m_curDownsample = 0;
        #endregion


        public RadialBlur() { name = "Graphi_FullScreen_RadialBlur"; }

        /// <summary>
        /// 屏蔽 SceneView 场景视图的显示
        /// </summary>
        protected override bool executeInSceneView => false;


        /// <summary>
        /// 创建纹理
        /// </summary>
        /// <param name="name"></param>
        /// <param name="scal"></param>
        /// <returns></returns>
        private RTHandle CreateRT(string name, float scal = 1.0f)
        {
            return RTHandles.Alloc
                (
                    Vector2.one * scal,
                    TextureXR.slices,
                    dimension: TextureXR.dimension,
                    useDynamicScale: true,
                    colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
                    name: name
                ); ;
        }

        private void ReleaseDownsampleTexs()
        {
            m_DownsampleTex?.Release();
            m_DownsampleResult?.Release();
        }

        private void CreateDownsampleTexs()
        {
            if (m_curDownsample == m_Downsample) { return; }
            ReleaseDownsampleTexs();

            m_curDownsample = m_Downsample;
            float s = 1.0f / (int)m_curDownsample;
            m_DownsampleTex = CreateRT("Graphi Radial DownSample Tex", s);
            m_DownsampleResult = CreateRT("Graphi Radial DownSample TexResult", s);
        }


        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            m_Shader = ShaderFind.Get(4, ShaderFind.E_GraInclude.FullScreen);
            if (m_Shader != null)
                m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
            else
                Debug.LogError($"Not find shader. '{m_Shader.name}'");


            // 创建操作时的临时纹理
            CreateDownsampleTexs();
        }

        protected override void Execute(CustomPassContext ctx)
        {
            CreateDownsampleTexs();

            // 降采样
            CustomPassUtils.Copy(ctx, ctx.cameraColorBuffer, m_DownsampleTex);

            // 径向模糊处理
            ctx.propertyBlock.SetTexture("_Tex", m_DownsampleTex);
            ctx.propertyBlock.SetVector("_Params", new Vector4(m_Center.x, m_Center.y, m_Intensity, m_Internation));
            ctx.propertyBlock.SetFloat("_ScaleBias", (int)m_curDownsample);

            CoreUtils.SetRenderTarget(ctx.cmd, m_DownsampleResult, ClearFlag.None);
            CoreUtils.DrawFullScreen(ctx.cmd, m_Material, ctx.propertyBlock, shaderPassId: 0);

            // 拷贝回摄像机缓冲中
            CustomPassUtils.Copy(ctx, m_DownsampleResult, ctx.cameraColorBuffer);
        }


        protected override void Cleanup()
        {
            if (m_Material != null)
                CoreUtils.Destroy(m_Material);
            ReleaseDownsampleTexs();
            m_curDownsample = 0;
        }
    }



#if UNITY_EDITOR
    [CustomPassDrawerAttribute(typeof(RadialBlur))]
    public class RadialBlurEditor : CustomPassDrawer
    {
        SerializedProperty prop_m_Downsample;
        SerializedProperty prop_m_Center;
        SerializedProperty prop_m_Intensity;
        SerializedProperty prop_m_Internation;

        RadialBlur.DownsampleEnum curDownsample;
        bool canEditCenter = false;
        GUIStyle helpBoxStyle;


        /// <summary>
        /// 初始化 Inspector 属性
        /// </summary>
        /// <param name="customPass"></param>
        protected override void Initialize(SerializedProperty customPass)
        {
            prop_m_Center = customPass.FindPropertyRelative("m_Center");
            prop_m_Intensity = customPass.FindPropertyRelative("m_Intensity");
            prop_m_Internation = customPass.FindPropertyRelative("m_Internation");
            prop_m_Downsample = customPass.FindPropertyRelative("m_Downsample");

            curDownsample = (RadialBlur.DownsampleEnum)prop_m_Downsample.boxedValue;

            helpBoxStyle = new GUIStyle("FrameBox");
            helpBoxStyle.richText = true;
            helpBoxStyle.fontSize = 10;
            helpBoxStyle.alignment = TextAnchor.UpperLeft;
        }

        /// <summary>
        /// 渲染
        /// </summary>
        /// <param name="customPass"></param>
        /// <param name="rect"></param>
        protected override void DoPassGUI(SerializedProperty customPass, Rect rect)
        {
            rect.y += 10;

            EditorGUI.PropertyField(rect, prop_m_Downsample, new GUIContent("Downsample"));
            rect.y += GetSingleH(prop_m_Downsample, 5);

            EditorGUI.indentLevel++;
            canEditCenter = EditorGUI.Toggle(rect, new GUIContent("Manual editing (center position)"), canEditCenter);
            rect.y += 20;
            EditorGUI.BeginDisabledGroup(!canEditCenter);
            EditorGUI.PropertyField(rect, prop_m_Center, new GUIContent("Radial center position"));
            EditorGUI.EndDisabledGroup();
            rect.y += GetSingleH(prop_m_Center, 5);
            rect.y += 5;
            rect.height = 20;
            EditorGUI.indentLevel--;

            if (curDownsample != (RadialBlur.DownsampleEnum)prop_m_Downsample.boxedValue)
            {
                curDownsample = (RadialBlur.DownsampleEnum)prop_m_Downsample.boxedValue;
                float s = 1.0f / ((int)prop_m_Downsample.boxedValue * 2);
                prop_m_Center.boxedValue = new Vector2(s, s);
            }


            EditorGUI.PropertyField(rect, prop_m_Internation, new GUIContent("Iteration"));
            rect.y += GetSingleH(prop_m_Internation, 5);

            EditorGUI.PropertyField(rect, prop_m_Intensity, new GUIContent("Force"));
            rect.y += GetSingleH(prop_m_Intensity, 5);

            rect.y += 10;
        }

        /// <summary>
        /// 单个属性的 GUI 高度
        /// </summary>
        /// <param name="prop"></param>
        /// <returns></returns>
        private float GetSingleH(SerializedProperty prop, float addh = 0.0f)
        {
            return EditorGUI.GetPropertyHeight(prop) + EditorGUIUtility.standardVerticalSpacing + addh;
        }

        /// <summary>
        /// Inspector 总高度
        /// </summary>
        /// <param name="customPass"></param>
        /// <returns></returns>
        protected override float GetPassHeight(SerializedProperty customPass)
        {
            return base.GetPassHeight(customPass) + 60;
        }

        /// <summary>
        /// 隐藏默认设置
        /// </summary>
        protected override PassUIFlag commonPassUIFlags => PassUIFlag.None;
    }
#endif
}