using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 四角星
    /// <para>作者：强辰</para>
    /// </summary>
    public class Shuriken : BMesh
    {
        #region 序列化数据
        public Vector4 m_Layout = new Vector4(1.5f, 2.0f, 0.5f, 0.5f);
        #endregion


        public Shuriken() : base("Shuriken") { }

        protected override void OnCreateMesh(ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            MshFactory.Shuriken(m_Layout, ref vertices, ref uv0s, ref triangles);

        }
    }



#if UNITY_EDITOR
    [CustomEditor(typeof(Shuriken))]
    internal class ShurikenEditor : BMeshEditor
    {
        protected override void Descs()
        {
            EditorGUILayout.HelpBox(
                "x :  长度，y :  高度，z :  内角长度，w :  内角高度", MessageType.None);
        }


        [MenuItem("GameObject/Graphi/3D Object/四角星")]
        static private void CreateInHierarchy()
        {
            BMesh.PrivateObject(typeof(Shuriken));
        }
    }
#endif

}