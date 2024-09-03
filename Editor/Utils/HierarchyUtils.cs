using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ����� Hierarchy �б�����Ϸ���������ز����Ĺ�����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class HierarchyUtils : EditorWindow
    {
        #region ��Ϸ���󴴽�

        [MenuItem("GameObject/Graphi/Volume/OccDisplay")]
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


        [MenuItem("GameObject/Graphi/Profiler")]
        static private void Create_RuntimePerformance()
        {
            GameObject go = new GameObject("GraphicsProfiler");
            SetIcon(go, "Graphi-Analyze-Icon");
            go.AddComponent<RuntimePerformance>();
        }


        [MenuItem("GameObject/Graphi/Volume/Twist")]
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


        [MenuItem("GameObject/Graphi/Fx/Particle")]
        static private void Create_Fx()
        {
            //�� Hierarchy �б��д������Ӷ���
            string id = Mth.GenerateRandomNum(8);
            GameObject obj = new GameObject("Particle_" + id);
            ParticleSystem ps = obj.AddComponent<ParticleSystem>();
            SetIcon(obj, "Graphi-ParticleObj-Icon");


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

            EditorGUIUtility.PingObject(obj);
            Selection.activeObject = obj;
        }


        [MenuItem("GameObject/Graphi/3D Object/Tetrahedrons")]
        static private void Create_Tetrahedrons()
        {
            BMesh.PrivateObject(typeof(Tetrahedrons));
        }
        [MenuItem("GameObject/Graphi/3D Object/Shuriken")]
        static private void Create_Shuriken()
        {
            BMesh.PrivateObject(typeof(Shuriken));
        }
        [MenuItem("GameObject/Graphi/3D Object/Lozenge")]
        static private void Create_Lozenge()
        {
            BMesh.PrivateObject(typeof(Lozenge));
        }
        [MenuItem("GameObject/Graphi/3D Object/Flat")]
        static private void Create_Flat()
        {
            BMesh.PrivateObject(typeof(Flat));
        }

        #endregion


        /// <summary>
        /// Ϊ��Ϸ��������ͼ��
        /// </summary>
        /// <param name="go">��Ϸ����</param>
        /// <param name="icon">ͼ���ļ����������ļ�����׺��</param>
        static public void SetIcon(GameObject go, string icon)
        {
            EditorGUIUtility.SetIconForObject(go, AssetDatabase.LoadAssetAtPath<Texture2D>(Tools.FindexactFile("Editor/Images", $"{icon}.png")));
        }


        /// <summary>
        /// ��ȡ Hierarchy �б�����Ϸ�����·��
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