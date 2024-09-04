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
    /// ����� Hierarchy �б�����Ϸ���������ز����Ĺ�����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class HierarchyUtils : EditorWindow
    {
        /// <summary>
        /// Ϊ��Ϸ��������ͼ��
        /// </summary>
        /// <param name="go">��Ϸ����</param>
        /// <param name="icon">ͼ���ļ����������ļ�����׺��</param>
        static public void SetIcon(GameObject go, string icon)
        {
            EditorGUIUtility.SetIconForObject(go, AssetDatabase.LoadAssetAtPath<Texture2D>(ProjectUtils.FindexactFile("Editor/Images", $"{icon}.png")));
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



        /// <summary>
        /// ��������
        /// </summary>
        /// <param name="p">���ʱ���·��������·����</param>
        /// <param name="shadername">���ʰ󶨵���ɫ��</param>
        static private Material CreateMat(string p, string shadername)
        {
            if (string.IsNullOrEmpty(p) || string.IsNullOrEmpty(shadername)) { return null; }
            Material mat = new Material(ShaderFind.GetTradition(shadername));
            AssetDatabase.CreateAsset(mat, p);
            AssetDatabase.Refresh();
            return mat;
        }
        /// <summary>
        /// �����
        /// </summary>
        /// <param name="length">���������</param>
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
            //�� Hierarchy �б��д������Ӷ���
            string id = GenerateRandomNum(8);
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
            Material mat = CreateMat($"Assets/ParticleMaterial_{id}.mat", "Graphi/Fx/ParticleStandard"); // �趨����
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

            // �������
            GameObject go = new GameObject(objname);
            CustomPassVolume cpv = go.AddComponent<CustomPassVolume>();
            cpv.injectionPoint = CustomPassInjectionPoint.BeforeTransparent;
            cpv.isGlobal = true;

            // ������ɫ��1����Ҫ����Ⱦͨ��
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
            drcp.overrideMaterial = CreateMat($"{savepath}occdisplaydepth.mat", "Graphi/CustomPass/DrawCustomObjectColorAndDepthBuffer"); // ����
            drcp.overrideDepthState = false;
            drcp.overrideStencil = false;
            drcp.sortingCriteria = SortingCriteria.CommonOpaque;

            // ������ɫ��2����Ҫ����Ⱦͨ��
            CustomPass cp2 = CustomPass.CreateFullScreenPass(null);
            FullScreenCustomPass fscp = (FullScreenCustomPass)cp2;
            fscp.name = "OccDisplayDraw";
            fscp.clearFlags = ClearFlag.None;
            fscp.fetchColorBuffer = false;
            fscp.fullscreenPassMaterial = CreateMat($"{savepath}occdisplaydraw_{GenerateRandomNum(6)}.mat", "Graphi/FullScreen/OccDisplay"); // ����

            // ���
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

            //�����Զ�����Ⱦͨ��Volume
            GameObject go = new GameObject(objname);
            CustomPassVolume cpv = go.AddComponent<CustomPassVolume>();
            cpv.injectionPoint = CustomPassInjectionPoint.BeforePostProcess;
            cpv.isGlobal = true;

            //�����Զ�����Ⱦ���޸Ĳ���
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

            //���
            cpv.customPasses.Add(drcp);

            EditorGUIUtility.PingObject(go);
            SetIcon(go, "Graphi-TwistRP-Icon");
        }

    }
}