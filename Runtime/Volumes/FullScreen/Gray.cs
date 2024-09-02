using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
using UnityEditor.Rendering.HighDefinition;
using UnityEditor;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ȫ���Ҷ�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    class Gray : CustomPass
    {
        [Range(0, 1)]
        public float m_Brightness = 0.5f;


        Shader m_Shader;
        Material m_Mat;
        Vector4 m_Params;
        RTHandle m_Src;


        public Gray() { name = "Graphi_FullScreen_Gray"; }


        protected override bool executeInSceneView => false;


        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            m_Shader = ShaderFind.Get(2, ShaderFind.E_GraInclude.FullScreen);
            m_Mat = CoreUtils.CreateEngineMaterial(m_Shader);
            m_Src = RTHandles.Alloc(
                        Vector2.one,
                        TextureXR.slices,
                        dimension: TextureXR.dimension,
                        useDynamicScale: true,
                        colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
                        name: "Graphi_FullScreen_Gray_TempTex"
                    );
        }

        protected override void Execute(CustomPassContext ctx)
        {
            CustomPassUtils.Copy(ctx, ctx.cameraColorBuffer, m_Src);

            m_Params.Set(m_Brightness, 0.0f, 1.0f, 0.0f);
            ctx.propertyBlock.SetVector("_Params", m_Params);
            ctx.propertyBlock.SetTexture("_Tex", m_Src);
            CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer, ClearFlag.None);
            CoreUtils.DrawFullScreen(ctx.cmd, m_Mat, ctx.propertyBlock, shaderPassId: 0);
        }


        protected override void Cleanup()
        {
            CoreUtils.Destroy(m_Mat);
            m_Src.Release();
        }
    }

#if UNITY_EDITOR
    /// <summary>
    /// ��չ Inspector ������壨 Gray ��
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    [CustomPassDrawerAttribute(typeof(Gray))]
    public class GrayCustomPassDrawer : CustomPassDrawer
    {
        SerializedProperty prop_m_Brightness;

        protected override void Initialize(SerializedProperty customPass)
        {
            prop_m_Brightness = customPass.FindPropertyRelative("m_Brightness");
        }
        protected override void DoPassGUI(SerializedProperty customPass, Rect rect)
        {
            rect.y += 10;
            EditorGUI.PropertyField(rect, prop_m_Brightness, new GUIContent("������"), true);
            rect.y += GetH(prop_m_Brightness);
        }

        /// <summary>
        /// ��Inspector�У�ÿ���Զ�����������и�
        /// </summary>
        /// <param name="p"></param>
        /// <param name="adddist"></param>
        /// <returns></returns>
        private float GetH(SerializedProperty p, float adddist = 0.0f)
        {
            return EditorGUI.GetPropertyHeight(p) + EditorGUIUtility.standardVerticalSpacing + adddist;
        }

        /// <summary>
        /// Inspector �ܸ߶�
        /// </summary>
        /// <param name="customPass"></param>
        /// <returns></returns>
        protected override float GetPassHeight(SerializedProperty customPass)
        {
            return base.GetPassHeight(customPass) + 20;
        }

        /// <summary>
        /// ����unity�ṩ��Ĭ�ϱ�ǩ���ڻҶ���Ⱦ�����У������޸�Ĭ���ṩ�ı�ǩ��
        /// </summary>
        protected override PassUIFlag commonPassUIFlags => PassUIFlag.None;
    }
#endif
}