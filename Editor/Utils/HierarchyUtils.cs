using System;
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 负责对 Hierarchy 列表内游戏对象进行相关操作的工具类
    /// <para>作者：强辰</para>
    /// </summary>
    public class HierarchyUtils : EditorWindow
    {
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



        /// <summary>
        /// 创建材质
        /// </summary>
        /// <param name="p">材质保存路径（完整路径）</param>
        /// <param name="shadername">材质绑定的着色器</param>
        static private Material CreateMat(string p, string shadername)
        {
            if (string.IsNullOrEmpty(p) || string.IsNullOrEmpty(shadername)) { return null; }
            Material mat = new Material(ShaderFind.GetTradition(shadername));
            AssetDatabase.CreateAsset(mat, p);
            AssetDatabase.Refresh();
            return mat;
        }
        /// <summary>
        /// 随机数
        /// </summary>
        /// <param name="length">随机数长度</param>
        /// <returns></returns>
        static private string GenerateRandomNum(int length)
        {
            StringBuilder result = new StringBuilder();
            for (var i = 0; i < length; i++)
            {
                var r = new System.Random(Guid.NewGuid().GetHashCode());
                result.Append(r.Next(0, 10));
            }
            return result.ToString();
        }


        [MenuItem("GameObject/Graphi Profiler")]
        static private void Create_GProfiler()
        {
            GameObject go = new GameObject("GProfiler");
            SetIcon(go, "Graphi-Analyze-Icon");
            go.AddComponent<GProfiler>();
            EditorGUIUtility.PingObject(go);
        }



        [MenuItem("GameObject/Effects/Graphi_Particle")]
        static private void Create_Fx()
        {
            //在 Hierarchy 列表中创建粒子对象
            string id = GenerateRandomNum(8);
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
            Material mat = CreateMat($"Assets/ParticleMaterial_{id}.mat", "Graphi/Fx/ParticleStandard"); // 设定材质
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



        [MenuItem("GameObject/Volume/Graphi_OccDisplay")]
        static private void Create_OccDisplay()
        {
            string savepath = "Assets/";

            int layid = 1 << LayerMask.NameToLayer(Lay.C_BuildinLayer[2]);
            if (layid < 0)
            {
                Debug.LogError("occdisplay layer does not exist.");
                return;
            }

            string objname = "OccDisplay";
            if (GameObject.Find(objname) != null)
            {
                Debug.LogError("already exist in scene.");
                return;
            }

            // 创建体积
            GameObject go = new GameObject(objname);
            CustomPassVolume cpv = go.AddComponent<CustomPassVolume>();
            cpv.injectionPoint = CustomPassInjectionPoint.BeforeTransparent;
            cpv.isGlobal = true;

            // 创建着色第1步需要的渲染通道
            CustomPass cp = CustomPass.CreateDrawRenderersPass
            (
                CustomPass.RenderQueueType.AllOpaque,
                layid,
                null,
                targetColorBuffer: CustomPass.TargetBuffer.Custom,
                targetDepthBuffer: CustomPass.TargetBuffer.Custom,
                clearFlags: ClearFlag.All,
                overrideMaterialPassName: "Draw CustomObject Color And Depth Buffer"
            );
            DrawRenderersCustomPass drcp = (DrawRenderersCustomPass)cp;
            drcp.name = "OccDisplayDrawDepth";
            drcp.overrideMode = DrawRenderersCustomPass.OverrideMaterialMode.Material;
            drcp.overrideMaterial = CreateMat($"{savepath}occdisplaydepth.mat", "Graphi/CustomPass/DrawCustomObjectColorAndDepthBuffer"); // 材质
            drcp.overrideDepthState = false;
            drcp.overrideStencil = false;
            drcp.sortingCriteria = SortingCriteria.CommonOpaque;

            // 创建着色第2步需要的渲染通道
            CustomPass cp2 = CustomPass.CreateFullScreenPass(null);
            FullScreenCustomPass fscp = (FullScreenCustomPass)cp2;
            fscp.name = "OccDisplayDraw";
            fscp.clearFlags = ClearFlag.None;
            fscp.fetchColorBuffer = false;
            fscp.fullscreenPassMaterial = CreateMat($"{savepath}occdisplaydraw_{GenerateRandomNum(6)}.mat", "Graphi/FullScreen/OccDisplay"); // 材质

            // 添加
            cpv.customPasses.Add(drcp);
            cpv.customPasses.Add(fscp);

            EditorGUIUtility.PingObject(go);
            SetIcon(go, "Graphi-OccDisplay-Icon");
        }



        [MenuItem("GameObject/Volume/Graphi_Twist")]
        static private void Create_TwistDrive()
        {
            int layid = 1 << LayerMask.NameToLayer(Lay.C_BuildinLayer[0]);
            if (layid < 0)
            {
                Debug.LogError("twist layer does not exist.");
                return;
            }

            string objname = "TwistDrive";
            if (GameObject.Find(objname) != null)
            {
                Debug.LogError("already exist in scene.");
                return;
            }

            //创建自定义渲染通道Volume
            GameObject go = new GameObject(objname);
            CustomPassVolume cpv = go.AddComponent<CustomPassVolume>();
            cpv.injectionPoint = CustomPassInjectionPoint.BeforePostProcess;
            cpv.isGlobal = true;

            //创建自定义渲染并修改参数
            CustomPass cp = CustomPass.CreateDrawRenderersPass(
                CustomPass.RenderQueueType.LowTransparent,
                layid,
                overrideMaterial: null,
                sorting: UnityEngine.Rendering.SortingCriteria.CommonTransparent | UnityEngine.Rendering.SortingCriteria.CommonOpaque,
                targetColorBuffer: CustomPass.TargetBuffer.Camera,
                targetDepthBuffer: CustomPass.TargetBuffer.Camera,
                clearFlags: UnityEngine.Rendering.ClearFlag.None
                );
            cp.name = objname;

            DrawRenderersCustomPass drcp = (DrawRenderersCustomPass)cp;
            drcp.overrideMode = DrawRenderersCustomPass.OverrideMaterialMode.None;
            drcp.overrideDepthState = true;
            drcp.depthWrite = false;

            //添加
            cpv.customPasses.Add(drcp);

            EditorGUIUtility.PingObject(go);
            SetIcon(go, "Graphi-TwistRP-Icon");
        }

    }
}