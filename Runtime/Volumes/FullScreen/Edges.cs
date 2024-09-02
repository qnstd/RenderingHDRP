using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
using UnityEditor.Rendering.HighDefinition;
using UnityEditor;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 全屏渲染处理 - 描边
    /// <para>作者：强辰</para>
    /// </summary>
    class Edges : CustomPass
    {
        public LayerMask m_Layer = 0;
        [ColorUsage(false, true)]
        public Color m_Color = Color.white;
        public float m_Threshold = 1;
        public float m_Width = 1;

        Shader m_Shader;
        Material m_Mat;
        RTHandle m_RT;


        public Edges() { name = "Graphi_FullScreen_Edges"; }

        protected override bool executeInSceneView => false;


        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            m_Shader = ShaderFind.Get(3, ShaderFind.E_GraInclude.FullScreen);
            m_Mat = CoreUtils.CreateEngineMaterial(m_Shader);
            m_RT = RTHandles.Alloc
                (
                    Vector2.one,
                    TextureXR.slices,
                    dimension: TextureXR.dimension,
                    useDynamicScale: true,
                    colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
                    name: "Graphi Edges Objs Tex"
                );
        }

        protected override void Execute(CustomPassContext ctx)
        {
            CoreUtils.SetRenderTarget(ctx.cmd, m_RT, ClearFlag.Color);
            CustomPassUtils.DrawRenderers(ctx, m_Layer);

            ctx.propertyBlock.SetColor("_Color", m_Color);
            ctx.propertyBlock.SetTexture("_Tex", m_RT);
            ctx.propertyBlock.SetFloat("_Threshold", m_Threshold);
            ctx.propertyBlock.SetFloat("_Width", m_Width);

            CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer, ClearFlag.None);
            CoreUtils.DrawFullScreen(ctx.cmd, m_Mat, ctx.propertyBlock, shaderPassId: 0);
        }


        protected override void Cleanup()
        {
            CoreUtils.Destroy(m_Mat);
            m_RT.Release();
        }
    }

#if UNITY_EDITOR

    [CustomPassDrawerAttribute(typeof(Edges))]
    public class EdgesCustomPassDrawer : CustomPassDrawer
    {
        SerializedProperty prop_Layer;
        SerializedProperty prop_Color;
        SerializedProperty prop_Width;
        SerializedProperty prop_Threshold;

        const float YOffset = 10.0f;

        protected override void Initialize(SerializedProperty customPass)
        {
            prop_Layer = customPass.FindPropertyRelative("m_Layer");
            prop_Color = customPass.FindPropertyRelative("m_Color");
            prop_Width = customPass.FindPropertyRelative("m_Width");
            prop_Threshold = customPass.FindPropertyRelative("m_Threshold");
        }

        protected override void DoPassGUI(SerializedProperty customPass, Rect rect)
        {
            rect.y += YOffset;
            EditorGUI.PropertyField(rect, prop_Layer, new GUIContent("渲染层级"), true);
            rect.y += GetH(prop_Layer);
            EditorGUI.PropertyField(rect, prop_Color, new GUIContent("颜色"), true);
            rect.y += GetH(prop_Color);
            EditorGUI.PropertyField(rect, prop_Width, new GUIContent("宽度"), true);
            rect.y += GetH(prop_Width);
            EditorGUI.PropertyField(rect, prop_Threshold, new GUIContent("亮度阔值"), true);
            rect.y += GetH(prop_Threshold);
        }

        private float GetH(SerializedProperty p, float adddist = 0.0f)
        {
            return EditorGUI.GetPropertyHeight(p) + EditorGUIUtility.standardVerticalSpacing + adddist;
        }

        protected override float GetPassHeight(SerializedProperty customPass)
        {
            return base.GetPassHeight(customPass) + YOffset + 10;
        }

        protected override PassUIFlag commonPassUIFlags => PassUIFlag.None;
    }

#endif
}