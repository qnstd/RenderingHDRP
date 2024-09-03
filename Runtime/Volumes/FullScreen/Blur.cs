using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Rendering.HighDefinition;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 全屏自定义渲染管道 - 模糊
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    public class Blur : CustomPass
    {
        #region 对外参数
        [FieldAttr("Iteration")]
        public int m_iteration = 4;

        [FieldAttr("Blur")]
        public float m_blur = 3f;

        [FieldAttr("Scale")]
        [Range(0.1f, 1)]
        public float m_Scale = 0.5f;

        [FieldAttr("Parameter")]
        public Texture2DParameter m_Tex2dParameter = new Texture2DParameter(null, false);

        [FieldAttr("Force")]
        [Range(0, 1)]
        public float m_Intensity = 0.01f;

        [FieldAttr("Reverse")]
        public bool m_Reverse = false;
        #endregion

        #region 变量
        // 材质、着色器
        [SerializeField, HideInInspector]
        Shader m_shader;
        Material m_mat;
        // 临时纹理
        RTHandle m_rt1;
        RTHandle m_rt2;
        // 临时纹理的缩放因子
        float m_CurScale = 0;
        #endregion


        public Blur() { name = "Graphi_FullScreen_Blur"; }


        /// <summary>
        /// 不允许在Scene试图显示自定义渲染
        /// </summary>
        protected override bool executeInSceneView => false;


        /// <summary>
        /// 初始化
        /// </summary>
        /// <param name="renderContext"></param>
        /// <param name="cmd"></param>
        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            m_shader = ShaderFind.Get(0, ShaderFind.E_GraInclude.FullScreen);
            m_mat = CoreUtils.CreateEngineMaterial(m_shader);

            CreateAndUpdateRTs();
        }


        private void ReleaseRTs()
        {
            m_rt1?.Release();
            m_rt2?.Release();
        }

        private void CreateAndUpdateRTs()
        {
            if (m_CurScale == m_Scale) { return; }

            ReleaseRTs();

            m_CurScale = m_Scale;
            m_rt1 = CreateRTHandle("Graphi Blur TempRT1");
            m_rt2 = CreateRTHandle("Graphi Blur TempRT2");
        }


        /// <summary>
        /// 创建临时处理像素的纹理
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        private RTHandle CreateRTHandle(string name)
        {
            return RTHandles.Alloc
                (
                    Vector2.one * m_CurScale, //缩放因子
                    TextureXR.slices, // 通用纹理格式
                    dimension: TextureXR.dimension,
                    colorFormat: GraphicsFormat.B10G11R11_UFloatPack32, //颜色格式
                    useDynamicScale: true, //动态分辨率
                    name: name //纹理名称
                );
        }



        /// <summary>
        /// 绘制
        /// </summary>
        /// <param name="ctx">绘制上下文</param>
        /// <param name="rt">绘制目标纹理</param>
        /// <param name="mat">渲染材质</param>
        /// <param name="passID">材质的PassID</param>
        protected void Draw(CustomPassContext ctx, RTHandle rt, Material mat, int passID)
        {
            CommandBuffer _cmd = ctx.cmd;
            CoreUtils.SetRenderTarget(_cmd, rt, ClearFlag.None);
            CoreUtils.DrawFullScreen(_cmd, mat, ctx.propertyBlock, shaderPassId: passID);
        }


        /// <summary>
        /// 每帧执行
        /// </summary>
        /// <param name="ctx"></param>
        protected override void Execute(CustomPassContext ctx)
        {
            CreateAndUpdateRTs();


            CustomPassUtils.Copy(ctx, ctx.cameraColorBuffer, m_rt1);

            for (int i = 0; i < m_iteration; i++)
            {
                // 设置参数
                ctx.propertyBlock.SetFloat("_Blur", m_blur * (i + 1));
                ctx.propertyBlock.SetFloat("_Scal", 1 / m_CurScale);

                ctx.propertyBlock.SetTexture("_SourceTex", m_rt1);
                Draw(ctx, m_rt2, m_mat, 0); // 高斯-纵向
                ctx.propertyBlock.SetTexture("_SourceTex", m_rt2);
                Draw(ctx, m_rt1, m_mat, 1); // 高斯-横向
            }

            RTHandle final = m_rt1;
            if (m_Tex2dParameter != null && m_Tex2dParameter.value != null)
            {// 附加纹理效果
                ctx.propertyBlock.SetFloat("_Scal", 1 / m_CurScale);
                ctx.propertyBlock.SetTexture("_SourceTex", m_rt1);
                ctx.propertyBlock.SetTexture("_STex", m_Tex2dParameter.value);
                ctx.propertyBlock.SetFloat("_Intensity", m_Intensity);
                ctx.propertyBlock.SetInt("_Reverse", m_Reverse ? -1 : 1);
                Draw(ctx, m_rt2, m_mat, 2);
                final = m_rt2;
            }

            CustomPassUtils.Copy(ctx, final, ctx.cameraColorBuffer);
        }


        /// <summary>
        /// 在Disable时进行调用
        /// </summary>
        protected override void Cleanup()
        {
            CoreUtils.Destroy(m_mat);
            ReleaseRTs();
            m_CurScale = 0;
        }
    }


#if UNITY_EDITOR
    /// <summary>
    /// 扩展 Inspector 操作面板（ Blur ）
    /// <para>作者：强辰</para>
    /// </summary>
    [CustomPassDrawerAttribute(typeof(Blur))]
    public class BlurCustomPassDrawer : CustomPassDrawer
    {
        List<Field> lst = new List<Field>();

        float _Yoffset;
        GUIStyle _HelpBoxStyle;


        protected override void Initialize(SerializedProperty customPass)
        {
            Tools.GetFieldInfo(target.GetType(), customPass, ref lst);

            _HelpBoxStyle = new GUIStyle("FrameBox");
            _HelpBoxStyle.richText = true;
            _HelpBoxStyle.fontSize = 10;
            _HelpBoxStyle.alignment = TextAnchor.UpperLeft;
        }


        protected override void DoPassGUI(SerializedProperty customPass, Rect rect)
        {
            _Yoffset = 0;
            rect.y += 10;
            _Yoffset += 10;

            Tools.ShowFieldInfo(lst, ref rect, GetH);

            _Yoffset += 10;
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
            return base.GetPassHeight(customPass) + _Yoffset;
        }

        /// <summary>
        /// 屏蔽unity提供的默认标签，在模糊渲染过程中，无需修改默认提供的标签项
        /// </summary>
        protected override PassUIFlag commonPassUIFlags => PassUIFlag.None;
    }
#endif
}