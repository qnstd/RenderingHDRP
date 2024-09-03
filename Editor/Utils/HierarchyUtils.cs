using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 负责对 Hierarchy 列表内游戏对象进行相关操作的工具类
    /// <para>作者：强辰</para>
    /// </summary>
    public class HierarchyUtils : EditorWindow
    {
        #region 游戏对象创建

        [MenuItem("GameObject/Volume/Graphi_OccDisplay")]
        static private void Create_OccDisplay()
        {
            if (Application.isPlaying)
            {
                Gui.Dialog("Non-Operational on runtime.");
                return;
            }

            string savepath = "Assets/";

            GameObject obj = GraphiMachine.CreateOccDisplayDrawCustomPass
                (
                     CreateShaderMat.Excute2($"{savepath}occdisplaydepth.mat", "Graphi/CustomPass/DrawCustomObjectColorAndDepthBuffer"),
                     CreateShaderMat.Excute2($"{savepath}occdisplaydraw_{Mth.GenerateRandomNum(6)}.mat", "Graphi/FullScreen/OccDisplay")
                );
            if (obj != null)
                SetIcon(obj, "Graphi-OccDisplay-Icon");
        }

        [MenuItem("GameObject/Volume/Graphi_Twist")]
        static private void Create_TwistDiver()
        {
            if (Application.isPlaying)
            {
                Gui.Dialog("Non-Operational on runtime.");
                return;
            }

            string layer = GraphiMachine.C_BuildinLayer[0];
            Lay.AddLayer(layer);

            if (GameObject.Find(layer) != null)
            {
                Gui.Dialog("Twist rendering volume already exists.");
                return;
            }

            GameObject go = GraphiMachine.CreateDrawRendererCustomPassTwist();
            if (go != null)
            {
                EditorGUIUtility.PingObject(go);
                SetIcon(go, "Graphi-TwistRP-Icon");
            }
        }


        [MenuItem("GameObject/Graphi Profiler")]
        static private void Create_RuntimePerformance()
        {
            GameObject go = new GameObject("GraphicsProfiler");
            SetIcon(go, "Graphi-Analyze-Icon");
            go.AddComponent<RuntimePerformance>();
        }


        [MenuItem("GameObject/Effects/Graphi_Particle")]
        static private void Create_Fx()
        {
            //在 Hierarchy 列表中创建粒子对象
            string id = Mth.GenerateRandomNum(8);
            GameObject obj = new GameObject("Particle_" + id);
            ParticleSystem ps = obj.AddComponent<ParticleSystem>();
            SetIcon(obj, "Graphi-ParticleObj-Icon");


            //TODO：修改粒子对象绑定的粒子系统数据
            //开启自定义数据并为自定义数据1,2设置默认值
            var customData = ps.customData;
            customData.enabled = true;
            customData.SetMode(ParticleSystemCustomData.Custom1, ParticleSystemCustomDataMode.Vector);
            customData.SetMode(ParticleSystemCustomData.Custom2, ParticleSystemCustomDataMode.Vector);
            customData.SetVectorComponentCount(ParticleSystemCustomData.Custom1, 2); //将数据 1 和 2 的Vector长度设置两个。因为zw无法使用
            customData.SetVectorComponentCount(ParticleSystemCustomData.Custom2, 2);

            //开启Renderer下自定义数据流并进行相关数据填充
            ParticleSystemRenderer psr = obj.GetComponent<ParticleSystemRenderer>();
            Material mat = CreateShaderMat.Excute2($"Assets/ParticleMaterial_{id}.mat", "Graphi/Fx/ParticleStandard"); // 设定材质
            psr.sharedMaterial = mat;

            //***
            //  填充的数据顺序不能改变，必须是以下顺序。顺序依赖特效粒子通用着色器的顶点数据顺序。
            //***
            List<ParticleSystemVertexStream> streams = new List<ParticleSystemVertexStream>()
            {
                ParticleSystemVertexStream.Position, //顶点位置
                ParticleSystemVertexStream.Normal, //法线
                ParticleSystemVertexStream.Tangent, //切线
                ParticleSystemVertexStream.Color, //顶点颜色
                ParticleSystemVertexStream.Custom1XYZW, //自定义数据1
                ParticleSystemVertexStream.Custom2XYZW, //自定义数据2
                ParticleSystemVertexStream.UV //UV
            };
            psr.SetActiveVertexStreams(streams);
            //END

            EditorGUIUtility.PingObject(obj);
            Selection.activeObject = obj;
        }


        static private void CreateCustomMeshObject(Type t)
        {
            string name = t.Name;
            GameObject go = new GameObject(name);
            go.AddComponent(t);

            // 设置对象icon
            string iconPath = ProjectUtils.FindexactFile("Editor/Images", $"Graphi-Mesh-{name}-Icon.png");
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
        [MenuItem("GameObject/3D Object/Graphi_Tetrahedrons")]
        static private void Create_Tetrahedrons()
        {
            CreateCustomMeshObject(typeof(Tetrahedrons));
        }
        [MenuItem("GameObject/3D Object/Graphi_Shuriken")]
        static private void Create_Shuriken()
        {
            CreateCustomMeshObject(typeof(Shuriken));
        }
        [MenuItem("GameObject/3D Object/Graphi_Lozenge")]
        static private void Create_Lozenge()
        {
            CreateCustomMeshObject(typeof(Lozenge));
        }
        [MenuItem("GameObject/3D Object/Graphi_Flat")]
        static private void Create_Flat()
        {
            CreateCustomMeshObject(typeof(Flat));
        }

        #endregion


        /// <summary>
        /// 为游戏对象设置图标
        /// </summary>
        /// <param name="go">游戏对象</param>
        /// <param name="icon">图标文件名（不带文件名后缀）</param>
        static public void SetIcon(GameObject go, string icon)
        {
            EditorGUIUtility.SetIconForObject(go, AssetDatabase.LoadAssetAtPath<Texture2D>(ProjectUtils.FindexactFile("Editor/Images", $"{icon}.png")));
        }


        /// <summary>
        /// 获取 Hierarchy 列表中游戏对象的路径
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        static public string GetGameObjectHierarchyPath(GameObject obj)
        {
            if (!obj.transform.parent)
                return obj.transform.name;

            return GetGameObjectHierarchyPath(obj.transform.parent.gameObject) + "/" + obj.transform.name;
        }

    }
}