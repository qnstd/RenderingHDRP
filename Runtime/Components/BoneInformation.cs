using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;


#if UNITY_EDITOR
using UnityEditor;
#endif

namespace com.graphi.renderhdrp
{

#if UNITY_EDITOR

    /// <summary>
    /// 骨骼信息
    /// <para>作者：强辰</para>
    /// </summary>
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class BoneInformation : MonoBehaviour
    {
        #region Inspector 
        [FieldAttr("Show Bone Wireframe")]
        public bool drawBoneGizmos = true;
        [FieldAttr("Show Bone Name")]
        public bool drawBoneName = false;
        [FieldAttr("Bone Size")]
        [Range(0.001f, 0.01f)]
        public float boneSize = 0.0025f;
        [FieldAttr("Bone Color")]
        public Color boneColor = Color.red;
        [FieldAttr("Bone Name Color")]
        public Color boneNameColor = Color.white;
        [FieldAttr("Bone Line Color")]
        public Color connectLineColor = new Color(1.0f, 0.8f, 0.0f, 1.0f);
        [FieldAttr("Bone Name Background Color")]
        public Color boneNameBgColor = new Color(0.3570863f, 0.563387f, 0.7232704f, 1.0f);
        #endregion


        internal SkinnedMeshRenderer[] m_Smrs = null;
        internal HashSet<Transform> m_Bones = null;
        internal Transform[] m_AllTrans = null;



        private void OnEnable()
        {
            m_AllTrans = GetComponentsInChildren<Transform>();
            m_Smrs = transform.GetComponentsInChildren<SkinnedMeshRenderer>();
            m_Bones = new HashSet<Transform>();

            foreach (SkinnedMeshRenderer smr in m_Smrs)
            {
                Transform[] bones = smr.bones;
                int len = bones.Length;
                for (int j = 0; j < len; j++)
                {
                    m_Bones.Add(bones[j]);
                }
            }
        }

        private void OnDestroy()
        {
            Array.Clear(m_Smrs, 0, m_Smrs.Length);
            m_Bones.Clear();
            Array.Clear(m_AllTrans, 0, m_AllTrans.Length);

            m_Smrs = null;
            m_Bones = null;
            m_AllTrans = null;
        }



        /// <summary>
        /// 绘制骨骼信息
        /// <para>只在非运行时状态下，且在 SceneView 窗体下执行</para>
        /// </summary>
        private void OnDrawGizmos()
        {
            if (drawBoneGizmos && enabled)
            {
                foreach (Transform t in m_AllTrans)
                {
                    if (m_Bones.Contains(t))
                    {
                        Handles.color = boneColor;
                        Handles.DrawWireCube(t.position, t.localScale * boneSize);
                    }

                    if (t.parent != null)
                    {
                        Handles.color = connectLineColor;
                        Handles.DrawLine(t.parent.position, t.position);
                    }
                }
            }
        }

    }



    [CustomEditor(typeof(BoneInformation))]
    internal class BoneInformationEditor : Editor
    {
        BoneInformation Target;
        List<Field> m_FieldList = new List<Field>();
        internal GUIStyle labelStyle = null;


        private void OnEnable()
        {
            Target = target as BoneInformation;
            Tools.GetFieldInfo(typeof(BoneInformation), serializedObject, ref m_FieldList);
        }


        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.LabelField("Only SceneView", EditorStyles.linkLabel);
            EditorGUILayout.Space(3);
            EditorGUI.indentLevel++;
            Tools.ShowFieldInfo(m_FieldList);
            EditorGUI.indentLevel--;
            serializedObject.ApplyModifiedProperties();
        }


        /// <summary>
        /// 在 SceneView 下（也只可在此窗体下）执行
        /// </summary>
        protected virtual void OnSceneGUI()
        {
            if (labelStyle == null)
                labelStyle = new GUIStyle("Badge") { richText = true, fontSize = 10 };

            if (Target.drawBoneGizmos && Target.enabled)
            {
                Handles.color = Target.boneColor;
                foreach (Transform bone in Target.m_Bones)
                {
                    float size = Target.boneSize;
                    if (Handles.Button(bone.position, bone.rotation, size, size, (int controlID, Vector3 position, Quaternion rotation, float size, EventType eventType) =>
                    {
                        if (Event.current.type == EventType.Layout)
                        {
                            Handles.RectangleHandleCap(controlID, position, rotation, size, eventType);
                        }
                        Handles.DrawWireCube(bone.position, bone.localScale * size);

                    }))
                    {
                        Tools.LocationElement(bone, false);
                        Event.current.Use();
                    }

                    if (Target.drawBoneName)
                    {// 骨骼名称
                        Color c = GUI.backgroundColor;
                        GUI.backgroundColor = Target.boneNameBgColor;

                        Vector3 p = bone.position;
                        p.x += Target.boneSize;
                        Handles.Label(p, "<color=#" + Target.boneNameColor.ToHexString() + ">" + bone.name + "</color>", labelStyle);

                        GUI.backgroundColor = c;
                    }
                }
            }
        }
    }


#endif

}