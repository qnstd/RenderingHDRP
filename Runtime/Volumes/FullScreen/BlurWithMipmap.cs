using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEditor.Rendering.HighDefinition;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 静态模糊效果（轻量级模糊处理，利用颜色金字塔的Mipmap实现）
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    public class BlurWithMipmap : CustomPass
    {
        #region 对外参数

        [Range(0, 7)]
        public int m_MipmapLv = 4;
        [Range(0, 1)]
        public float m_Brightness = 1.0f;

        #endregion

        // 材质
        Material m_Mat;
        // 透传参数
        Vector4 m_RenderParam;


        public BlurWithMipmap()
        {
            name = "Graphi BlurWithMipmap";
        }


        protected override bool executeInSceneView => false;


        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            try
            {
                Shader sha = ShaderFind.Get(5, ShaderFind.E_GraInclude.FullScreen);
                m_Mat = CoreUtils.CreateEngineMaterial(sha);
            }
            catch (Exception) { }

        }

        protected override void Execute(CustomPassContext ctx)
        {
            if (m_Mat == null) { return; }

            MaterialPropertyBlock block = ctx.propertyBlock;

            m_RenderParam.Set(m_MipmapLv, m_Brightness, 0, 0);
            block.SetVector("_RenderParam", m_RenderParam);

            CoreUtils.DrawFullScreen(ctx.cmd, m_Mat, block, 0);

        }

        protected override void Cleanup()
        {
            CoreUtils.Destroy(m_Mat);
        }
    }

#if UNITY_EDITOR

    [CustomPassDrawerAttribute(typeof(BlurWithMipmap))]
    internal class BlurWithMipmapCustomPassDraw : CustomPassDrawer
    {
        List<SerializedProperty> lst = new List<SerializedProperty>();
        GUIStyle _HelpBoxStyle;

        protected override void Initialize(SerializedProperty customPass)
        {
            FieldInfo[] fields = typeof(BlurWithMipmap).GetFields(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
            foreach (FieldInfo fi in fields)
            {
                lst.Add(customPass.FindPropertyRelative(fi.Name));
            }

            _HelpBoxStyle = new GUIStyle("FrameBox");
            _HelpBoxStyle.richText = true;
            _HelpBoxStyle.fontSize = 10;
            _HelpBoxStyle.alignment = TextAnchor.UpperLeft;
        }

        protected override void DoPassGUI(SerializedProperty customPass, Rect rect)
        {
            rect.y += 10;
            for (int i = 0; i < lst.Count; i++)
            {
                SerializedProperty prop = lst[i];
                EditorGUI.PropertyField(rect, prop, true);
                rect.y += GetH(prop);
            }

            rect.y += 5;
            rect.height = 20;
            EditorGUI.BeginDisabledGroup(true);
            EditorGUI.TextArea
                (
                    rect,
                    "It is recommended that shaders insert nodes as：<color=#fbb843> Before PostProcess (Injection Point) </color>.",
                    _HelpBoxStyle
                );
            EditorGUI.EndDisabledGroup();
        }

        private float GetH(SerializedProperty p, float adddist = 0.0f)
        {
            return EditorGUI.GetPropertyHeight(p) + EditorGUIUtility.standardVerticalSpacing + adddist;
        }

        protected override float GetPassHeight(SerializedProperty customPass)
        {
            return base.GetPassHeight(customPass) + 35;
        }

        protected override PassUIFlag commonPassUIFlags => PassUIFlag.None;

    }
#endif
}
