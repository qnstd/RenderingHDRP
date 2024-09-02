using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 菱形
    /// <para>作者：强辰</para>
    /// </summary>
    public class Lozenge : BMesh
    {
        #region 序列化数据
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
                "x :  长度，y :  厚度，z :  高度", MessageType.None);
        }


        [MenuItem("GameObject/Graphi/3D Object/菱形")]
        static private void CreateInHierarchy()
        {
            BMesh.PrivateObject(typeof(Lozenge));
        }
    }
#endif
}