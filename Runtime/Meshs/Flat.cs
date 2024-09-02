using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 以左下角为（0，0，0）点的平面
    /// <para>作者：强辰</para>
    /// </summary>
    public class Flat : BMesh
    {
        #region 序列化数据
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
                "Layout  :  平面的行列数据， Size   :  平面每个单元格尺寸", MessageType.None);
        }

        [MenuItem("GameObject/Graphi/3D Object/平面")]
        static private void CreateInHierarchy()
        {
            BMesh.PrivateObject(typeof(Flat));
        }
    }
#endif
}