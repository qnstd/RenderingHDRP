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
    /// �������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    [RequireComponent(typeof(MeshFilter))]
    [RequireComponent(typeof(MeshRenderer))]
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class BMesh : MonoBehaviour
    {
        /// <summary>
        /// ����
        /// </summary>
        protected Mesh msh = null;
        /// <summary>
        /// ���������
        /// </summary>
        protected MeshFilter filter = null;
        /// <summary>
        /// ��������
        /// </summary>
        protected string meshname = "";


        /// <summary>
        /// ����
        /// </summary>
        /// <param name="mshname">��������</param>

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
            // ���ö���/uv0/�����档uv��ֵҪ���ڶ��㸳ֵ������ᱨuv���鳤���붥�����鳤�Ȳ�ƥ�����⡣
            msh.vertices = vertices;
            msh.uv = uv0s;
            msh.triangles = triangles;

            // ���㷨�ߣ�����
            msh.RecalculateNormals();
            msh.RecalculateTangents();
        }


        /// <summary>
        /// ������������
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


        #region ����ʵ��
        /// <summary>
        /// ��ʼ��
        /// </summary>
        protected virtual void OnStart() { }
        /// <summary>
        /// �ͷ�
        /// </summary>
        protected virtual void OnDispose() { }
        /// <summary>
        /// ������Ϣ��������������/uv/�����棩
        /// </summary>
        /// <param name="vertices">�������飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="uv0s">uv0���飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="triangles">���������飨������Ҫ�ֶ���ʼ����</param>
        protected virtual void OnCreateMesh(ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles) { }
        #endregion


        // Editor Logic
#if UNITY_EDITOR
        /// <summary>
        /// �� Hierarchy �д����������
        /// </summary>
        /// <param name="classType">����������</param>
        static public void PrivateObject(Type classType)
        {
            string name = classType.Name;
            GameObject go = new GameObject(name);
            go.AddComponent(classType);

            // ���ö���icon
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
            if (GUILayout.Button("��������", GUILayout.Width(80), GUILayout.Height(20)))
            {
                ResetMesh();
            }
            GUI.backgroundColor = c;
            GUI.backgroundColor = Color.yellow;
            if (GUILayout.Button("��������", GUILayout.Width(80), GUILayout.Height(20)))
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