using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class Lozenge : BMesh
    {
        #region ���л�����
        public Vector3 m_Layout = new Vector3(2, 2, 3);
        #endregion


        public Lozenge() : base("Lozenge") { }

        protected override void OnCreateMesh(ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            MshFactory.Lozenge(m_Layout, ref vertices, ref uv0s, ref triangles);
        }
    }



#if UNITY_EDITOR
    [CustomEditor(typeof(Lozenge))]
    internal class LozengeEditor : BMeshEditor
    {
        protected override void Descs()
        {
            EditorGUILayout.HelpBox(
                "x :  Width\ny :  Thickness\nz :  Height", MessageType.None);
        }



    }
#endif
}