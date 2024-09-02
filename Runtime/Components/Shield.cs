using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    #region 护盾撞击点信息结构
    public class ShieldTouchInfo
    {
        private float m_Intensity;
        private float m_ChangeSpeed;
        private bool m_Increase = true;

        /// <summary>
        /// 撞击点影响的范围（半径）
        /// </summary>
        public float Radius { get; private set; }
        /// <summary>
        /// 撞击点
        /// </summary>
        public Vector4 Point { get; private set; }
        /// <summary>
        /// 强度
        /// </summary>
        public float Intensity { get; private set; }
        /// <summary>
        /// 移除标记
        /// </summary>
        internal bool DelMark { get; set; } = false;


        public ShieldTouchInfo
            (
                Vector4 p,
                float radius,
                float intensity,
                float changeSpeed
            )
        {
            Point = p;
            Radius = radius;
            m_Intensity = intensity;
            m_ChangeSpeed = changeSpeed;
        }

        /// <summary>
        /// 刷新数据
        /// </summary>
        public void RefreshInfos()
        {
            float t = Time.deltaTime * m_ChangeSpeed;
            if (m_Increase)
            {
                Intensity += t;
                if (Intensity >= m_Intensity)
                {
                    Intensity = m_Intensity;
                    m_Increase = false;
                }
            }
            else
            {
                Intensity -= t;
                if (Intensity <= 0.0f)
                {
                    Intensity = 0.0f;
                    DelMark = true;
                }
            }
        }
    }
    #endregion


    /// <summary>
    /// 护盾
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    public class Shield : MonoBehaviour
    {
        #region 着色器材质相关操作
        const string SHADER_NAME = "Graphi/Fx/Shield"; // 着色器
        int TouchNumbers_ID = Shader.PropertyToID("_TouchNumbers");
        int TouchPoints_ID = Shader.PropertyToID("_TouchPoints");
        int TouchPointDatas_ID = Shader.PropertyToID("_TouchPointDatas");
        Material m_Mat;
        void GetShieldMat()
        {
            MeshRenderer mr = GetComponent<MeshRenderer>();
            if (mr != null)
            {
                Material[] mats = mr.sharedMaterials;
                if (mats != null && mats.Length != 0)
                {
                    foreach (Material m in mats)
                    {
                        if (m != null && m.shader != null && m.shader.name == SHADER_NAME)
                        {
                            m_Mat = m; // 记录护盾材质并跳出。如果材质组还绑定了使用同样护盾着色器的其他材质，则忽视。
                            break;
                        }
                    }
                }
            }
            if(m_Mat == null)
                Lg.Err
                    (
                        string.Format("未找到 {0} 着色器! Shader = {1}", "护盾", SHADER_NAME)
                    );
        }
        private bool ExistShieldMat() { return m_Mat != null; }

        private void ShaderDataInput()
        {
            if(m_Mat == null) { return; }

            // 透传数据至着色器
            m_Mat.SetFloat(TouchNumbers_ID, m_Data.Count);
            m_Mat.SetVectorArray(TouchPoints_ID, m_Points);
            m_Mat.SetVectorArray(TouchPointDatas_ID, m_PointDatas);
        }
        #endregion


        #region 逻辑操作
        private List<ShieldTouchInfo> m_Data = null; // 撞击点数据组

        // 用于Shader着色器使用的撞击点数据
        private Vector4[] m_Points = null;
        private Vector4[] m_PointDatas = null;

        private void CreateTouchDatasForShader()
        {
            if (m_Points != null)
                Array.Clear(m_Points, 0, m_Points.Length);
            if (m_PointDatas != null)
                Array.Clear(m_PointDatas, 0, m_PointDatas.Length);
            m_Points = null;
            m_PointDatas = null;

            // 重新创建
            m_Points = new Vector4[m_TouchNum];
            m_PointDatas = new Vector4[m_TouchNum];
            Array.Fill<Vector4>(m_Points, Vector4.zero);
            Array.Fill<Vector4>(m_PointDatas, Vector4.zero);
        } 
        // 结束


        private void Awake()
        {
            GetShieldMat();

            m_Data = new List<ShieldTouchInfo>();
            CreateTouchDatasForShader();
        }


        private void Update()
        {
            if (!ExistShieldMat()) { return; }

            int datalen = m_Data.Count;
            if(datalen != 0)
            {
                // 调整数据并向着色器提供可交互的渲染数据
                for (int i = 0; i < datalen; i++)
                {
                    ShieldTouchInfo info = m_Data[i];
                    info.RefreshInfos();
                    m_Points[i] = info.Point;
                    m_PointDatas[i].Set(info.Radius, info.Intensity, 0, 0); // Vector4.xyzw 参数具体代表的含义请查看同名的着色器文件
                }

                // 透传着色器参数
                ShaderDataInput();

                // 移除操作完毕的撞击点
                int delnum = 
                m_Data.RemoveAll((info) => { return info.DelMark; });
            }
        }
        #endregion


        #region 对外参数
        [Range(0, 100)] public int m_TouchNum = 20; // 最大撞击点数
        public float m_DistanceBetweenTouchPoints = 0.01f; // 撞击点间距最小值
        #endregion


        /// <summary>
        /// 添加护盾撞击点信息
        /// </summary>
        /// <param name="p">撞击点</param>
        /// <param name="radius">以撞击点为中心的半径</param>
        /// <param name="intensity">撞击强度</param>
        /// <param name="changeSpeed">撞击强度的变化速度（无->最大->无）</param>
        public void AddTouchInfo
            (
                Vector4 p,
                float radius = 0.3f,
                float intensity = 0.15f,
                float changeSpeed = 1f
            )
        {
            if (m_Data.Count >= m_TouchNum) { return; /* 达到最大处理数 */ }
            int i = m_Data.FindIndex((info) =>
            {
                if (Vector4.Distance(info.Point, p) < m_DistanceBetweenTouchPoints) { return true; /* 参数点与维护数组内的某一点距离太近，不做处理. */ }
                return false;
            });

            if (i == -1)
                m_Data.Add(new ShieldTouchInfo(p, radius, intensity, changeSpeed));
        }
    }


    #region Shield 脚本的 Inspector GUI
#if UNITY_EDITOR

    [CustomEditor(typeof(Shield))]
    internal class ShieldEditor : UnityEditor.Editor
    {
        SerializedProperty touchnum;
        SerializedProperty disBetweenTouchPoints;

        private void OnEnable()
        {
            touchnum = serializedObject.FindProperty("m_TouchNum");
            disBetweenTouchPoints = serializedObject.FindProperty("m_DistanceBetweenTouchPoints");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.Space(5);
            EditorGUILayout.PropertyField(touchnum, new GUIContent("撞击点最大值"));
            EditorGUILayout.Space(5);
            EditorGUILayout.PropertyField(disBetweenTouchPoints, new GUIContent("撞击点间距最小值"));
            EditorGUILayout.Space(5);

            EditorGUILayout.HelpBox(
                "说明\n" +
                "   此脚本可用于与护盾交互，以下是需要注意的相关事项。\n\n" +
                "· 撞击点最大值" +
                "   此值是允许在护盾上可创建的交互点最大数量。虽然是Slider滑块模式，但无法在运行时实时调整，原因是在于着色器方面。" +
                "可交互的撞击点数据是以数组方式将数据送入，但着色器方面规定，声明数组类型的变量需要固定长度，并且只能一次性设置，不" +
                "允许动态改变数组类型的长度，否则会弹出警告，导致交互效果异常。即使进行拖动调整，也无法修改数据长度及着色器内数组长" +
                "度。因此，若要调整最大撞击点需要退出运行时后进行设置，设置完毕并保存后再次启动进行测试。"
                , MessageType.Info);

            serializedObject.ApplyModifiedProperties();
        }
    }

#endif
    #endregion
}