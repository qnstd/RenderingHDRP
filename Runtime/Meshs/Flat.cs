using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// �����½�Ϊ��0��0��0�����ƽ��
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class Flat : BMesh
    {
        #region ���л�����
        public Vector2Int m_Layout = new Vector2Int(10, 10);
        public float m_Size = 1.0f;
        #endregion

        public Flat() : base("Flat") { }


        protected override void OnCreateMesh(ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            MshFactory.Flat(m_Layout, m_Size, ref vertices, ref uv0s, ref triangles);
        }
    }



#if UNITY_EDITOR
    [CustomEditor(typeof(Flat))]
    internal class FlatEditor : BMeshEditor
    {
        protected override void Descs()
        {
            EditorGUILayout.HelpBox(
                "Layout  :  Row And Col\nSize   :  Cell Size", MessageType.None);
        }
    }
#endif
}