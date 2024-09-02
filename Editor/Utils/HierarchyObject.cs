using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ��������� Hierarchy �б��ڴ�������
    /// <para>���ߣ�ǿ��</para>
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
            //�� Hierarchy �б��д������Ӷ���
            string id = Mth.GenerateRandomNum(8);
            GameObject obj = new GameObject("Particle_" + id);
            ParticleSystem ps = obj.AddComponent<ParticleSystem>();
            Tools.SetIcon(obj, "Graphi-ParticleObj-Icon");


            //TODO���޸����Ӷ���󶨵�����ϵͳ����
            //�����Զ������ݲ�Ϊ�Զ�������1,2����Ĭ��ֵ
            var customData = ps.customData;
            customData.enabled = true;
            customData.SetMode(ParticleSystemCustomData.Custom1, ParticleSystemCustomDataMode.Vector);
            customData.SetMode(ParticleSystemCustomData.Custom2, ParticleSystemCustomDataMode.Vector);
            customData.SetVectorComponentCount(ParticleSystemCustomData.Custom1, 2); //������ 1 �� 2 ��Vector����������������Ϊzw�޷�ʹ��
            customData.SetVectorComponentCount(ParticleSystemCustomData.Custom2, 2);

            //����Renderer���Զ�������������������������
            ParticleSystemRenderer psr = obj.GetComponent<ParticleSystemRenderer>();
            Material mat = CreateShaderMat.Excute2($"Assets/ParticleMaterial_{id}.mat", "Graphi/Fx/ParticleStandard"); // �趨����
            psr.sharedMaterial = mat;

            //***
            //  ��������˳���ܸı䣬����������˳��˳��������Ч����ͨ����ɫ���Ķ�������˳��
            //***
            List<ParticleSystemVertexStream> streams = new List<ParticleSystemVertexStream>()
            {
                ParticleSystemVertexStream.Position, //����λ��
                ParticleSystemVertexStream.Normal, //����
                ParticleSystemVertexStream.Tangent, //����
                ParticleSystemVertexStream.Color, //������ɫ
                ParticleSystemVertexStream.Custom1XYZW, //�Զ�������1
                ParticleSystemVertexStream.Custom2XYZW, //�Զ�������2
                ParticleSystemVertexStream.UV //UV
            };
            psr.SetActiveVertexStreams(streams);
            //END

            renderhdrp.Tools.LocationElement(mat, false);
        }

    }
}