using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// UI 视觉效果
    /// <para>作者：强辰</para>
    /// </summary>
    [ExecuteInEditMode] //编辑模式下可执行实时刷新
    [DisallowMultipleComponent] //不允许添加多个组件
    public class UiVFX : BaseMeshEffect
    {
        #region 对外参数
        public Material m_material = null;
        public float m_OutEdgeWidth = 0;
        public Vector2 m_ShadowOffsetDistance = Vector2.zero;
        #endregion


        #region 内部属性
        // 缓存顶点数据列表
        private List<UIVertex> m_vertexLst = new List<UIVertex>();
        // 阴影的UV偏移量
        private Vector4 m_ShadowUVOffsetDistance = Vector4.zero;
        #endregion



        /// <summary>
        /// 唤醒时操作
        /// </summary>
        protected override void Awake()
        {
            base.Awake();

            //创建Shader
            if (m_material == null)
            {
                Lg.Err("UiVFX material is null.");
                return;
            }

            // 设置材质
            base.graphic.material = m_material;

            //判断当前UI摄像机中的渲染通道是否包含TexCoord1和TexCoord2，如果不包含，则添加
            var ch = base.graphic.canvas.additionalShaderChannels;
            var addch = AdditionalCanvasShaderChannels.TexCoord1;
            if ((ch & addch) != addch)
                base.graphic.canvas.additionalShaderChannels |= addch; //添加texcoord1通道
            addch = AdditionalCanvasShaderChannels.TexCoord2;
            if ((ch & addch) != addch)
                base.graphic.canvas.additionalShaderChannels |= addch; //添加texcoord2通道

            //刷新
            Refresh();
        }


#if UNITY_EDITOR
        /// <summary>
        /// 只在编辑器模式内进行实时刷新
        /// </summary>
        protected override void OnValidate()
        {
            base.OnValidate();

            // 更新材质
            if (base.graphic != null && base.graphic.material != m_material)
                base.graphic.material = m_material;

            // 刷新
            if (base.graphic != null && base.graphic.material != null)
                Refresh();
        }
#endif


        /// <summary>
        /// 刷新材质参数
        /// </summary>
        private void Refresh()
        {
            Material mat = base.graphic.material;
            if (mat == null) { return; }

            //透传参数
            mat.SetFloat("_OutEdgeWidth", m_OutEdgeWidth);
            mat.SetVector("_ShadowDist", m_ShadowUVOffsetDistance);

            //重绘
            base.graphic.SetVerticesDirty();
        }


        /// <summary>
        /// 定义网格
        /// </summary>
        /// <param name="vh"></param>
        public override void ModifyMesh(VertexHelper vh)
        {
            //先获取当前的网格数据
            vh.GetUIVertexStream(m_vertexLst);

            //操作
            Operate();

            //清理并重新设置网格顶点三角面数据
            vh.Clear();
            vh.AddUIVertexTriangleStream(m_vertexLst);
        }


        //重新计算网格顶点及UV
        private void Operate()
        {
            for (int i = 0, count = m_vertexLst.Count - 3; i <= count; i += 3)
            {
                var v1 = m_vertexLst[i];
                var v2 = m_vertexLst[i + 1];
                var v3 = m_vertexLst[i + 2];

                // 计算三个点组成三角形的中心点
                var minX = _Min(v1.position.x, v2.position.x, v3.position.x);
                var minY = _Min(v1.position.y, v2.position.y, v3.position.y);
                var maxX = _Max(v1.position.x, v2.position.x, v3.position.x);
                var maxY = _Max(v1.position.y, v2.position.y, v3.position.y);
                var posCenter = new Vector2(minX + maxX, minY + maxY) * 0.5f;

                // 计算原始UV框（范围）
                var uvMin = _Min(v1.uv0, v2.uv0, v3.uv0);
                var uvMax = _Max(v1.uv0, v2.uv0, v3.uv0);
                var uvOrigin = new Vector4(uvMin.x, uvMin.y, uvMax.x, uvMax.y);

                // 计算原始顶点坐标和UV的方向
                Vector2 triX, triY, uvX, uvY;
                Vector2 pos1 = v1.position;
                Vector2 pos2 = v2.position;
                Vector2 pos3 = v3.position;
                if (Mathf.Abs(Vector2.Dot((pos2 - pos1).normalized, Vector2.right)) > Mathf.Abs(Vector2.Dot((pos3 - pos2).normalized, Vector2.right)))
                {
                    triX = pos2 - pos1;
                    triY = pos3 - pos2;
                    uvX = v2.uv0 - v1.uv0;
                    uvY = v3.uv0 - v2.uv0;
                }
                else
                {
                    triX = pos3 - pos2;
                    triY = pos2 - pos1;
                    uvX = v3.uv0 - v2.uv0;
                    uvY = v2.uv0 - v1.uv0;
                }

                // 为每个顶点设置新的Position和UV，并传入原始UV框
                v1 = SetNewPosAndUV(v1, m_OutEdgeWidth, posCenter, triX, triY, uvX, uvY, uvOrigin, m_ShadowOffsetDistance, ref m_ShadowUVOffsetDistance);
                v2 = SetNewPosAndUV(v2, m_OutEdgeWidth, posCenter, triX, triY, uvX, uvY, uvOrigin, m_ShadowOffsetDistance, ref m_ShadowUVOffsetDistance);
                v3 = SetNewPosAndUV(v3, m_OutEdgeWidth, posCenter, triX, triY, uvX, uvY, uvOrigin, m_ShadowOffsetDistance, ref m_ShadowUVOffsetDistance);

                // 应用设置后的UIVertex
                m_vertexLst[i] = v1;
                m_vertexLst[i + 1] = v2;
                m_vertexLst[i + 2] = v3;
            }
        }


        static private UIVertex SetNewPosAndUV
        (
            UIVertex pVertex,
            float LineWidth,
            Vector2 pPosCenter,
            Vector2 pTriangleX,
            Vector2 pTriangleY,
            Vector2 pUVX,
            Vector2 pUVY,
            Vector4 pUVOrigin,
            Vector2 shadowdist,
            ref Vector4 shadowUVDist
        )
        {
            // 顶点新的位置
            Vector3 pos = pVertex.position;

            #region 外描边距离
            float posXOffset = pos.x > pPosCenter.x ? LineWidth : -LineWidth; //顶点x轴位置在中心点左侧，则减去外扩尺寸
            float posYOffset = pos.y > pPosCenter.y ? LineWidth : -LineWidth; //顶点y轴位置在中心点右侧，则加上外扩尺寸
            #endregion

            #region 阴影的偏移距离
            if ((pos.x > pPosCenter.x && shadowdist.x > 0) || (pos.x < pPosCenter.x && shadowdist.x < 0))
                posXOffset += shadowdist.x;
            if ((pos.y > pPosCenter.y && shadowdist.y > 0) || (pos.y < pPosCenter.y && shadowdist.y < 0))
                posYOffset += shadowdist.y;
            #endregion

            pos.x += posXOffset;
            pos.y += posYOffset;
            pVertex.position = pos;

            // 顶点新的UV
            Vector4 uv = pVertex.uv0;
            Vector2 v2 = (pUVX / pTriangleX.magnitude * posXOffset/*x轴增量*/) * (Vector2.Dot(pTriangleX, Vector2.right) > 0 ? 1 : -1 /*x轴增量方向*/);
            uv.x += v2.x;
            uv.y += v2.y;
            v2 = (pUVY / pTriangleY.magnitude * posYOffset/*y轴增量*/) * (Vector2.Dot(pTriangleY, Vector2.up) > 0 ? 1 : -1/*y轴增量方向*/);
            uv.x += v2.x;
            uv.y += v2.y;
            pVertex.uv0 = uv;

            // 阴影的UV偏移量
            Vector2 sUV = pUVX / pTriangleX.magnitude * shadowdist.x * (Vector2.Dot(pTriangleX, Vector2.right) > 0 ? 1 : -1);
            sUV += pUVY / pTriangleY.magnitude * shadowdist.y * (Vector2.Dot(pTriangleY, Vector2.up) > 0 ? 1 : -1);
            shadowUVDist.x = sUV.x;
            shadowUVDist.y = sUV.y;

            // 记录原始UV范围
            pVertex.uv1 = new Vector2(pUVOrigin.x, pUVOrigin.y);
            pVertex.uv2 = new Vector2(pUVOrigin.z, pUVOrigin.w);

            return pVertex;
        }

        static private float _Min(float pA, float pB, float pC)
        { return Mathf.Min(Mathf.Min(pA, pB), pC); }

        static private float _Max(float pA, float pB, float pC)
        { return Mathf.Max(Mathf.Max(pA, pB), pC); }

        static private Vector2 _Min(Vector2 pA, Vector2 pB, Vector2 pC)
        { return new Vector2(_Min(pA.x, pB.x, pC.x), _Min(pA.y, pB.y, pC.y)); }

        static private Vector2 _Max(Vector2 pA, Vector2 pB, Vector2 pC)
        { return new Vector2(_Max(pA.x, pB.x, pC.x), _Max(pA.y, pB.y, pC.y)); }

    }


#if UNITY_EDITOR

    /// <summary>
    /// 自定义 UiVFX 组件的 Inspector 编辑框
    /// <para>作者：强辰</para>
    /// </summary>
    [CustomEditor(typeof(UiVFX))]
    internal class UiVFXEditor : UnityEditor.Editor
    {
        SerializedProperty m_Material;
        SerializedProperty m_OutEdgeWidth;
        SerializedProperty m_ShadowUVOffset;

        private void OnEnable()
        {
            m_Material = serializedObject.FindProperty("m_material");
            m_OutEdgeWidth = serializedObject.FindProperty("m_OutEdgeWidth");
            m_ShadowUVOffset = serializedObject.FindProperty("m_ShadowOffsetDistance");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.Space(5);
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(m_Material, new GUIContent("Material"));

            EditorGUILayout.Space(10);
            EditorGUILayout.PropertyField(m_OutEdgeWidth, new GUIContent("Outline Width"));

            EditorGUILayout.Space(10);
            EditorGUILayout.PropertyField(m_ShadowUVOffset, new GUIContent("Shadow Offset"));
            if (EditorGUI.EndChangeCheck())
            { }

            EditorGUILayout.Space(5);

            serializedObject.ApplyModifiedProperties();
        }
    }

#endif
}