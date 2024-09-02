using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 负责快速在 Hierarchy 列表内创建对象
    /// <para>作者：强辰</para>
    /// </summary>
    public class HierarchyObject : EditorWindow
    {

        [MenuItem("GameObject/Graphi/Volume/OccDisplay")]
        static private void CreateOccDisplay()
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
                Tools.SetIcon(obj, "Graphi-OccDisplay-Icon");
        }



        [MenuItem("GameObject/Graphi/Profiler")]
        static private void Create_RuntimePerformance()
        {
            GameObject go = new GameObject("GraphicsProfiler");
            Tools.SetIcon(go, "Graphi-Analyze-Icon");
            go.AddComponent<RuntimePerformance>();
        }




        [MenuItem("GameObject/Graphi/Volume/Twist")]
        static private void CreateTwistDiver()
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
                Tools.SetIcon(go, "Graphi-TwistRP-Icon");
            }
        }



        [MenuItem("GameObject/Graphi/Fx/Particle")]
        static private void CreateFx()
        {
            //在 Hierarchy 列表中创建粒子对象
            string id = Mth.GenerateRandomNum(8);
            GameObject obj = new GameObject("Particle_" + id);
            ParticleSystem ps = obj.AddComponent<ParticleSystem>();
            Tools.SetIcon(obj, "Graphi-ParticleObj-Icon");


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

            renderhdrp.Tools.LocationElement(mat, false);
        }

    }
}