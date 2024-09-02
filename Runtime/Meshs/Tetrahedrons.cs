using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 四面体
    /// <para>作者：强辰</para>
    /// </summary>
    public class Tetrahedrons : BMesh
    {
        #region 序列化数据
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
                "x :  长度，y :  高度，z :  厚度", MessageType.None);
        }


        [MenuItem("GameObject/Graphi/3D Object/四面体")]
        static private void CreateInHierarchy()
        {
            BMesh.PrivateObject(typeof(Tetrahedrons));
        }
    }
#endif

}