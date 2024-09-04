using System;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 摄像机镜头运动模糊
    /// <para>作者：强辰</para>
    /// </summary>
    [Serializable, VolumeComponentMenu("Post-processing/Graphi/MotionBlur")]
    public sealed class MotionBlur : CustomPostProcessVolumeComponent, IPostProcessComponent
    {
        #region 对外参数
        public FloatParameter m_SpeedFactor = new FloatParameter(8.0f);
        public ClampedFloatParameter m_Intensity = new ClampedFloatParameter(0f, 0f, 1f);
        public IntParameter m_Intertion = new IntParameter(5);
        #endregion


        Shader m_Shader;
        Material m_Material;
        Matrix4x4 m_PreviousViewProjection;


        // 激活条件
        public bool IsActive() => m_Material != null && m_Intensity.value > 0f;

        // 不允许在Scene模式下显示
        public override bool visibleInSceneView => false;


        // 渲染通道的插入点
        public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;


        public override void Setup()
        {
            m_Shader = ShaderFind.Get(1, ShaderFind.E_GraInclude.PostProcess);
            if (m_Shader != null)
                m_Material = new Material(m_Shader);
            else
                Debug.LogError("Not find Shader.");
        }


        public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
        {
            if (m_Material == null)
                return;

            Camera cam = camera.camera;

            // 计算视空间矩阵与透视矩阵的乘积、逆矩阵
            m_Material.SetMatrix("_PreviousViewProjection", m_PreviousViewProjection);
            Matrix4x4 m44 = cam.projectionMatrix * cam.worldToCameraMatrix;
            m_Material.SetMatrix("_CurrentViewProjectionInverse", m44.inverse);
            m_PreviousViewProjection = m44;


            // 设置参数
            m_Material.SetInt("_Intertion", m_Intertion.value);
            m_Material.SetFloat("_Intensity", m_Intensity.value);
            m_Material.SetFloat("_SpedFactor", m_SpeedFactor.value);
            m_Material.SetTexture("_MainTex", source);

            // 绘制
            HDUtils.DrawFullScreen(cmd, m_Material, destination, shaderPassId: 0);
        }

        public override void Cleanup()
        {
            CoreUtils.Destroy(m_Material);
        }

    }

#if UNITY_EDITOR

    [CustomEditor(typeof(MotionBlur))]
    public class MotionBlurEditor : VolumeComponentEditor
    {
        SerializedDataParameter m_SpeedFactor;
        SerializedDataParameter m_Intensity;
        SerializedDataParameter m_Intertion;

        public override void OnEnable()
        {
            base.OnEnable();

            var o = new PropertyFetcher<MotionBlur>(serializedObject);
            m_SpeedFactor = Unpack(o.Find(x => x.m_SpeedFactor));
            m_Intensity = Unpack(o.Find(x => x.m_Intensity));
            m_Intertion = Unpack(o.Find(x => x.m_Intertion));
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.Space(10);

            PropertyField(m_SpeedFactor, new GUIContent("Speed"));
            PropertyField(m_Intensity, new GUIContent("Force"));
            PropertyField(m_Intertion, new GUIContent("Iteration"));

            EditorGUILayout.Space(10);
            EditorGUILayout.HelpBox("Note that, unlike the built-in MotionBlur, this effect is a screen-level operation based on post-processing. When the rendering camera attached to the Volume with this effect performs a shift change, it executes a speed cache on all pixels in the current window body and calculates them accordingly to get the MotionBlur effect.", MessageType.Info);
            EditorGUILayout.Space(5);
        }
    }

#endif
}