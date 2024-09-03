using System;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 后处理-Hue
    /// <para>作者：强辰</para>
    /// </summary>
    [Serializable, VolumeComponentMenu("Post-processing/Graphi/Hue")]
    public sealed class Hue : CustomPostProcessVolumeComponent, IPostProcessComponent
    {
        #region 对外参数
        public ClampedFloatParameter m_brightness = new ClampedFloatParameter(1f, 0f, 5f, false);
        public ClampedFloatParameter m_saturation = new ClampedFloatParameter(1f, 0f, 5f, false);
        public ClampedFloatParameter m_contrast = new ClampedFloatParameter(1f, 0f, 5f, false);
        public BoolParameter m_open = new BoolParameter(false);
        #endregion


        #region 变量
        //着色器
        //[SerializeField, HideInInspector] //加上标签是为了保证着色器能被成功的打包，保留对着色器的引用。如果不加，在构建打包后，着色器在没有被任何引用的情况下无法被打入包中，导致运行时由于找不到着色器报错
        Shader m_shader;
        //材质
        Material m_Material;
        #endregion


        /// <summary>
        /// 是否可激活后处理
        /// </summary>
        /// <returns></returns>
        public bool IsActive() => m_Material != null && m_open.value;

        /// <summary>
        /// 设置插入点（在后处理之后）
        /// </summary>
        public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

        /// <summary>
        /// 不允许在Scene试图显示后处理效果
        /// </summary>
        public override bool visibleInSceneView => false;

        /// <summary>
        /// 初始化
        /// </summary>
        public override void Setup()
        {
            m_shader = ShaderFind.Get(0, ShaderFind.E_GraInclude.PostProcess);
            if (m_shader != null)
                m_Material = CoreUtils.CreateEngineMaterial(m_shader);
            else
                Lg.Err($"Not find '{m_shader.name}'.");
        }


        /// <summary>
        /// 渲染
        /// </summary>
        /// <param name="cmd">渲染指令</param>
        /// <param name="camera">摄像机</param>
        /// <param name="source">源纹理</param>
        /// <param name="destination">目标纹理</param>
        public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
        {
            if (m_Material == null)
                return;

            //提交参数
            m_Material.SetFloat("_Brightness", m_brightness.value);
            m_Material.SetFloat("_Saturation", m_saturation.value);
            m_Material.SetFloat("_Contrast", m_contrast.value);
            m_Material.SetTexture("_SourceTex", source);

            //绘制
            HDUtils.DrawFullScreen(cmd, m_Material, destination, shaderPassId: 0);
        }


        /// <summary>
        /// 清理
        /// </summary>
        public override void Cleanup()
        {
            CoreUtils.Destroy(m_Material);
        }
    }

#if UNITY_EDITOR

    /// <summary>
    /// 自定义 Hue 后处理组件的 Inspector 编辑
    /// <para>作者：强辰</para>
    /// </summary>
    [CustomEditor(typeof(Hue))]
    sealed class HueEditor : VolumeComponentEditor
    {
        SerializedDataParameter m_Brightness;
        SerializedDataParameter m_Saturation;
        SerializedDataParameter m_Contrast;
        SerializedDataParameter m_Open;

        public override void OnEnable()
        {
            base.OnEnable();

            var o = new PropertyFetcher<Hue>(serializedObject);
            m_Brightness = Unpack(o.Find(x => x.m_brightness));
            m_Saturation = Unpack(o.Find(x => x.m_saturation));
            m_Contrast = Unpack(o.Find(x => x.m_contrast));
            m_Open = Unpack(o.Find(x => x.m_open));
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.Space(10);

            PropertyField(m_Open, new GUIContent("Enable"));
            PropertyField(m_Brightness, new GUIContent("Brightness"));
            PropertyField(m_Saturation, new GUIContent("Saturation"));
            PropertyField(m_Contrast, new GUIContent("Contrast"));

            EditorGUILayout.Space(10);
        }
    }

#endif

}