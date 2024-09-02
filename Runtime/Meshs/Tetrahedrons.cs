using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class Tetrahedrons : BMesh
    {
        #region ���л�����
        public Vector3 m_Layout = new Vector3(1.0f, 1.0f, 1.0f);
        #endregion


        public Tetrahedrons() : base("Tetrahedrons") { }

        protected override void OnCreateMesh(ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            MshFactory.Tetrahedrons(m_Layout, ref vertices, ref uv0s, ref triangles);
        }
    }

#if UNITY_EDITOR
    [CustomEditor(typeof(Tetrahedrons))]
    internal class TetrahedronsEditor : BMeshEditor
    {
        protected override void Descs()
        {
            EditorGUILayout.HelpBox(
                "x :  ���ȣ�y :  �߶ȣ�z :  ���", MessageType.None);
        }


        [MenuItem("GameObject/Graphi/3D Object/������")]
        static private void CreateInHierarchy()
        {
            BMesh.PrivateObject(typeof(Tetrahedrons));
        }
    }
#endif

}