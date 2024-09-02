using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 模型几何渲染着色器操作面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class GeometryOperate : EditorWindow
    {
        #region 常量
        const string C_GeometryNormalMatName = "Graphi_MeshGeometry_Normal";
        const string C_GeometryNormalShaName = "Hidden/Graphi/Tool/GeometryNormal";

        const string C_GeometryMeshMatName = "Graphi_MeshGeometry_LineFrame";
        const string C_GeometryMeshShaName = "Hidden/Graphi/Tool/GeometryMesh";

        const string C_MatProp_Color = "_Color";
        const string C_MatProp_Length = "_Length";
        const string C_MatProp_NormalSpace = "_SpaceType";
        #endregion



        /// <summary>
        /// 设置材质属性
        /// </summary>
        /// <param name="m"></param>
        static void SetMaterialProps(Material m)
        {
            GlobalDataSettings settings = GraphiSettings.GlobalSettings;

            m.SetColor(C_MatProp_Color, settings.m_GeometryColor);
            if (m.name == C_GeometryNormalMatName)
            {
                m.SetFloat(C_MatProp_Length, settings.m_GeometryNormalLength);
                m.SetFloat(C_MatProp_NormalSpace, (float)settings.m_GeometryNormalSpace);
            }
        }



        /// <summary>
        /// 获取 Renderer 对象
        /// </summary>
        /// <param name="mr"></param>
        /// <returns></returns>
        static bool GetMeshRenderer(out Renderer mr)
        {
            mr = null;
            GameObject obj = Selection.activeGameObject;
            if (obj == null) { return false; }

            mr = obj.GetComponent<Renderer>();
            if (mr == null) { return false; }

            return true;
        }


        /// <summary>
        /// 绘制
        /// </summary>
        /// <param name="matname"></param>
        /// <param name="shadername"></param>
        /// <param name="matprop"></param>
        static void Draw(string matname, string shadername, Action<Material> matprop)
        {
            if (!GetMeshRenderer(out Renderer mr)) { return; }

            Material[] mats = mr.sharedMaterials;
            int len = mats.Length;
            int indx = Array.FindIndex(mats, 0, o => o.name == matname);
            if (indx == -1)
            {// 添加材质
                Material m = CoreUtils.CreateEngineMaterial(shadername);
                m.name = matname;

                // 设置属性
                matprop?.Invoke(m);
                // END

                int newlen = len + 1;
                Material[] news = new Material[newlen];
                Array.Copy(mats, 0, news, 0, len);
                news[newlen - 1] = m;
                mr.sharedMaterials = news;
            }
            else
            {// 移除材质
                Material[] news = new Material[len - 1];
                Array.Copy(mats, 0, news, 0, indx);
                Array.Copy(mats, indx + 1, news, indx, len - (indx + 1));
                mr.sharedMaterials = news;
            }
        }


        /// <summary>
        /// 判断材质是否是几何体渲染的材质
        /// </summary>
        /// <param name="m"></param>
        /// <returns></returns>
        static bool IsGeometryMat(Material m)
        {
            return m.name == C_GeometryNormalMatName || m.name == C_GeometryMeshMatName;
        }


        #region MenuItem 菜单项

        [MenuItem("GameObject/Graphi/Geometric/Normal #N")]
        static void GeomeryNormalVS()
        {
            Draw(C_GeometryNormalMatName, C_GeometryNormalShaName, (Material m) =>
            {
                SetMaterialProps(m);
            });
        }

        [MenuItem("GameObject/Graphi/Geometric/Wireframe #M")]
        static void GeometryMesh()
        {
            Draw(C_GeometryMeshMatName, C_GeometryMeshShaName, (Material m) =>
            {
                SetMaterialProps(m);
            });
        }

        [MenuItem("GameObject/Graphi/Geometric/Close All #&D")]
        static void RemoveAllGeometryInActiveScene()
        {
            Scene scn = SceneManager.GetActiveScene();
            if (scn == null) { return; }

            Renderer[] mrs = GameObject.FindObjectsOfType<Renderer>();
            if (mrs == null || mrs.Length == 0) { return; }

            Renderer mr;
            Material[] temp, temp1;
            for (int i = 0; i < mrs.Length; i++)
            {
                mr = mrs[i];
                temp = mr.sharedMaterials;
                if (temp == null || temp.Length == 0) { continue; }

                temp1 = Array.FindAll(temp, m => { return IsGeometryMat(m); });
                if (temp1 == null || temp1.Length == 0) { continue; }

                List<Material> lst = new List<Material>();
                int k = 0;
                foreach (Material m in temp)
                {
                    if (IsGeometryMat(m)) { k++; continue; }
                    lst.Add(m);
                }
                if (k != 0)
                    mr.sharedMaterials = lst.ToArray();
            }
        }

        #endregion


        #region 静态公共函数

        /// <summary>
        /// 刷新
        /// </summary>
        static public void Update()
        {
            Renderer[] mrs = GameObject.FindObjectsOfType<Renderer>();
            foreach (Renderer mr in mrs)
            {
                Material[] mats = mr.sharedMaterials;
                foreach (Material m in mats)
                {
                    if (IsGeometryMat(m))
                    {
                        SetMaterialProps(m);
                    }
                }
            }

        }

        #endregion

    }
}