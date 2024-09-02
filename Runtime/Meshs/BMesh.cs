using System;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Formats.Fbx.Exporter;
#endif



namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 网格基类
    /// <para>作者：强辰</para>
    /// </summary>
    [RequireComponent(typeof(MeshFilter))]
    [RequireComponent(typeof(MeshRenderer))]
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class BMesh : MonoBehaviour
    {
        /// <summary>
        /// 网格
        /// </summary>
        protected Mesh msh = null;
        /// <summary>
        /// 网格过滤器
        /// </summary>
        protected MeshFilter filter = null;
        /// <summary>
        /// 网格名称
        /// </summary>
        protected string meshname = "";


        /// <summary>
        /// 构造
        /// </summary>
        /// <param name="mshname">网格名称</param>

        public BMesh(string mshname = "") { meshname = mshname; }


        private void CreateMesh()
        {
            if (msh != null)
            {
                msh.Clear();
            }
            else
            {
                msh = new Mesh();
                msh.name = meshname;
            }

            Vector3[] vertices = null;
            Vector2[] uv0s = null;
            int[] triangles = null;
            OnCreateMesh(ref vertices, ref uv0s, ref triangles);
            // 设置顶点/uv0/三角面。uv赋值要后于顶点赋值，否则会报uv数组长度与顶点数组长度不匹配问题。
            msh.vertices = vertices;
            msh.uv = uv0s;
            msh.triangles = triangles;

            // 计算法线，切线
            msh.RecalculateNormals();
            msh.RecalculateTangents();
        }


        /// <summary>
        /// 重置网格数据
        /// </summary>
        public void ResetMesh()
        {
            CreateMesh();
            filter.sharedMesh = msh;
        }



        private void Start()
        {
            filter = transform.GetComponent<MeshFilter>();
            ResetMesh();
            OnStart();
        }


        private void OnDestroy()
        {
            if (msh != null)
            {
                msh.Clear();
                CoreUtils.Destroy(msh);
                msh = null;
            }
            if (filter != null)
            {
                filter.sharedMesh = null;
                filter = null;
            }
            OnDispose();
        }


        #region 子类实现
        /// <summary>
        /// 初始化
        /// </summary>
        protected virtual void OnStart() { }
        /// <summary>
        /// 释放
        /// </summary>
        protected virtual void OnDispose() { }
        /// <summary>
        /// 网格信息创建（包含顶点/uv/三角面）
        /// </summary>
        /// <param name="vertices">顶点数组（数组需要手动初始化）</param>
        /// <param name="uv0s">uv0数组（数组需要手动初始化）</param>
        /// <param name="triangles">三角面数组（数组需要手动初始化）</param>
        protected virtual void OnCreateMesh(ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles) { }
        #endregion


        // Editor Logic
#if UNITY_EDITOR
        /// <summary>
        /// 在 Hierarchy 中创建网格对象
        /// </summary>
        /// <param name="classType">网格类类型</param>
        static public void PrivateObject(Type classType)
        {
            string name = classType.Name;
            GameObject go = new GameObject(name);
            go.AddComponent(classType);

            // 设置对象icon
            string iconPath = Tools.FindexactFile("Editor/Images", $"Graphi-Mesh-{name}-Icon.png");
            if (!string.IsNullOrEmpty(iconPath))
            {
                EditorGUIUtility.SetIconForObject(go, AssetDatabase.LoadAssetAtPath<Texture2D>(iconPath));
            }


            GameObject parent = Selection.activeGameObject;
            if (parent != null)
                go.transform.SetParent(parent.transform);

            go.transform.localScale = Vector3.one;
            go.transform.localRotation = Quaternion.identity;
            go.transform.localPosition = Vector3.zero;
        }
#endif
    }



#if UNITY_EDITOR
    [CustomEditor(typeof(BMesh))]
    internal class BMeshEditor : Editor
    {
        BMesh src = null;
        public void OnEnable()
        {
            src = target as BMesh;
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            Descs();
            ExtendGUI();
        }

        protected virtual void Descs() { }

        private void ExtendGUI()
        {
            EditorGUILayout.Space(5);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.Space(1);
            Color c = GUI.backgroundColor;
            GUI.backgroundColor = Color.green;
            if (GUILayout.Button("数据重置", GUILayout.Width(80), GUILayout.Height(20)))
            {
                ResetMesh();
            }
            GUI.backgroundColor = c;
            GUI.backgroundColor = Color.yellow;
            if (GUILayout.Button("保存网格", GUILayout.Width(80), GUILayout.Height(20)))
            {
                SaveMesh();
            }
            GUI.backgroundColor = c;
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.Space(5);
        }


        void ResetMesh() { src.ResetMesh(); }
        void SaveMesh()
        {
            MeshFilter filter = src.GetComponent<MeshFilter>();
            MeshRenderer renderer = src.GetComponent<MeshRenderer>();
            if (filter == null || filter.sharedMesh == null || renderer == null)
            {
                return;
            }
            ModelExporter.ExportObject($"Assets/{filter.sharedMesh.name}.fbx", src.gameObject);
            AssetDatabase.Refresh();
        }
    }
#endif
}