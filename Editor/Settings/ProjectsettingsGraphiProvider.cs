using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ProjectSettings Graphi��ɫ��
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class ProjectsettingsGraphiProvider
    {
        static bool m_Cnfoldout = true;

        static bool m_setFoldout = true;
        static bool m_layerFoldout = true;
        static bool m_shaderFoldout = true;
        static bool m_runGraphicsInclude = true;
        static bool m_runCustomPostProcess = true;
        static bool m_otherFoldout = true;


        static GUIStyle m_BtnStyle = null;
        static Color m_CompileBtnColor = new Color(120.0f / 255.0f, 218.0f / 255.0f, 1.0f);

        [SettingsProvider]
        static private SettingsProvider Graphi()
        {
            return new SettingsProvider("Project/Graphi", SettingsScope.Project)
            {
                deactivateHandler = () =>
                {
                },

                activateHandler = (s, r) =>
                {
                },

                guiHandler = (s) =>
                {
                    if (m_BtnStyle == null)
                        m_BtnStyle = new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 10 };

                    Gui.Space(20);
                    Gui.IndentLevelAdd(2);

                    Gui.Hor();
                    Gui.Label("Compile: ", new GUIStyle("LODSliderText") { richText = true, fontSize = 11 }, 100);
                    Color c = GUI.backgroundColor;
                    GUI.backgroundColor = m_CompileBtnColor;
                    Gui.Btn("Run", () => { Tools.CompileScripts(); }, new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 10, alignment = TextAnchor.MiddleCenter }, Gui.W(45), Gui.H(20));
                    GUI.backgroundColor = c;
                    Gui.EndHor();


                    #region ��Ⱦ������
                    Gui.Space(20);
                    GUIStyle sty = new GUIStyle("LODSliderText") { fontSize = 10 };
                    m_setFoldout = EditorGUILayout.Foldout(m_setFoldout, "Render Settings", true);
                    if (m_setFoldout)
                    {
                        Gui.IndentLevelAdd(2);
                        Gui.Space(5);
                        Gui.Vertical("helpbox");

                        #region �㼶����
                        m_layerFoldout = EditorGUILayout.Foldout(m_layerFoldout, "LayerMask", true);
                        if (m_layerFoldout)
                        {
                            Gui.IndentLevelAdd(2);
                            Gui.Space(5);

                            Gui.Label("The following layers are Graphi library built-in layers that need to be added before runtime.", sty);
                            sty = new GUIStyle("OL Title") { fontSize = 9 };
                            string[] lays = GraphiMachine.C_BuildinLayer;
                            for (int i = 0; i < lays.Length; i++)
                            {
                                Gui.Label("<color=#acd4f2ff>" + lays[i] + "</color>", sty);
                            }
                            Gui.IndentLevelSub(2);
                        }
                        #endregion

                        #region ��ɫ��
                        Gui.Space(20);
                        sty = new GUIStyle("LODSliderText") { richText = true, fontSize = 10 };
                        m_shaderFoldout = EditorGUILayout.Foldout(m_shaderFoldout, "Shader", true);
                        if (m_shaderFoldout)
                        {
                            Gui.IndentLevelAdd(2);
                            Gui.Space(5);

                            Gui.Hor();
                            Gui.Label("<color=#c3c3c3ff>Graphics Include</color>", sty, 450);
                            m_runGraphicsInclude = EditorGUILayout.Toggle(m_runGraphicsInclude);
                            Gui.EndHor();
                            Gui.Hor();
                            Gui.Label("<color=#c3c3c3ff>Global rendering configuration Custom post-processing includes item append</color>", sty, 450);
                            m_runCustomPostProcess = EditorGUILayout.Toggle(m_runCustomPostProcess);
                            Gui.EndHor();
                            Gui.Label("<color=#f47e8f><b>*</b></color> Ensure that the HDRP global configuration file exists in the project", sty);

                            Gui.IndentLevelSub(2);
                        }
                        #endregion

                        #region ����
                        Gui.Space(20);
                        m_otherFoldout = EditorGUILayout.Foldout(m_otherFoldout, "Other", true);
                        if (m_otherFoldout)
                        {
                            Gui.IndentLevelAdd(2);
                            Gui.Space(5);
                            Gui.Label($"ColorSpace��Linear��     {((PlayerSettings.colorSpace == ColorSpace.Linear) ? "<color=#6bff83>��</color>" : "<color=#ff6b6b>x</color>")}", sty);
                            Gui.IndentLevelSub(2);
                        }
                        Gui.Space(3);
                        #endregion

                        #region ������
                        Gui.Space(5);
                        Gui.Hor();
                        Gui.Space(1);
                        Gui.Btn("Set", () => { Operate(); }, m_BtnStyle, Gui.W(80), Gui.H(22));
                        Gui.EndHor();
                        #endregion

                        Gui.Space(5);
                        Gui.EndVertical();
                        Gui.IndentLevelSub(2);
                    }
                    #endregion


                    #region ������
                    Gui.Space(20);
                    m_Cnfoldout = EditorGUILayout.Foldout(m_Cnfoldout, new GUIContent("ScriptObject Settings"), true);
                    if (m_Cnfoldout)
                    {
                        Gui.Space(5);
                        Gui.IndentLevelAdd(2);
                        Gui.Vertical("helpbox");
                        Gui.Space(5);
                        Gui.Hor();
                        Gui.Label("GlobalSettings: ", 160);
                        Gui.Btn(" ", () => { PO(GraphiSettings.GlobalSettings); }, "ToolbarSearchTextFieldPopup", Gui.W(20), Gui.H(18));
                        Gui.EndHor();
                        Gui.Space(5);
                        Gui.EndVertical();
                        Gui.IndentLevelSub(2);
                    }
                    #endregion

                    Gui.IndentLevelSub(2);
                }
            };
        }


        static private void PO<T>(T t) where T : UnityEngine.Object
        {
            EditorGUIUtility.PingObject(t);
        }


        static private void SetColorSpaceForLinear() { PlayerSettings.colorSpace = ColorSpace.Linear; }


        /// <summary>
        /// ����
        /// </summary>
        static private void Operate()
        {
            // �㼶����
            LayerSettings();
            // ��ɫ��
            ShaderSettings();
            // ������ɫ�ռ�
            SetColorSpaceForLinear();

            // ˢ��
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Gui.Dialog("Finish��");
        }


        #region �㼶����
        static private void LayerSettings()
        {
            string[] lays = GraphiMachine.C_BuildinLayer;
            for (int i = 0; i < lays.Length; i++)
                Lay.AddLayer(lays[i]);
        }
        #endregion


        #region ��ɫ������
        static private void ShaderSettings()
        {
            if (m_runGraphicsInclude)
                AddtoGraphicsInclude(); // ��� GraphicsInclude ��
            if (m_runCustomPostProcess)
                InsertCustomDataPostProcess(); // ע���Զ��������Ⱦ��
        }
        static private void AddtoGraphicsInclude()
        {
            SerializedObject graphics = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/GraphicsSettings.asset")[0]);
            SerializedProperty it = graphics.GetIterator();
            SerializedProperty prop;
            bool b;
            Dictionary<ShaderFind.E_GraInclude, List<string>> lst = ShaderFind.C_GraIncludes;

            while (it.NextVisible(true))
            {
                if (it.name == "m_AlwaysIncludedShaders")
                {
                    Dictionary<ShaderFind.E_GraInclude, List<string>> dic = new Dictionary<ShaderFind.E_GraInclude, List<string>>();
                    foreach (ShaderFind.E_GraInclude e in lst.Keys)
                    {
                        lst.TryGetValue(e, out List<string> _lst);
                        for (int i = 0; i < _lst.Count; i++)
                        {
                            b = false;
                            for (int j = 0; j < it.arraySize; j++)
                            {
                                prop = it.GetArrayElementAtIndex(j);
                                if (prop.objectReferenceValue.ToString().StartsWith(_lst[i]))
                                {//����
                                    b = true;
                                    break;
                                }
                            }
                            if (!b)
                            {//���
                                dic.TryGetValue(e, out List<string> __lst);
                                if (__lst == null)
                                {
                                    __lst = new List<string>();
                                    dic.Add(e, __lst);
                                }
                                __lst.Add(_lst[i]);
                            }
                        }
                    }

                    if (dic.Count != 0)
                    {
                        foreach (ShaderFind.E_GraInclude e in dic.Keys)
                        {
                            dic.TryGetValue(e, out List<string> l);
                            for (int i = 0; i < l.Count; i++)
                            {
                                string sha = l[i].ToString();
                                int _i = it.arraySize;
                                it.InsertArrayElementAtIndex(_i);//���б�ĩβ׷��
                                prop = it.GetArrayElementAtIndex(_i);
                                prop.objectReferenceValue = ShaderFind.Get(sha, e);
                                Lg.Trace("Add to GraphicsInclude��" + sha);
                            }
                        }

                        graphics.ApplyModifiedProperties(); //���֮��Ӧ����Щ�ı���������ı���
                    }

                    break;
                }
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
        static private void InsertCustomDataPostProcess()
        {
            //��ȡ��ǰ�󶨵���Ⱦ�ܵ��е�ȫ�������ļ�
            RenderPipelineGlobalSettings gloset = GraphicsSettings.GetSettingsForRenderPipeline<HDRenderPipeline>();
            if (gloset == null)
            {
                Lg.Err("RenderPipeline is not HDRP.");
                return;
            }
            string[] guids = AssetDatabase.FindAssets(gloset.name);
            if (guids.Length == 0)
            {
                Lg.Err("HDRP GlobalSettings is not exist.");
                return;
            }
            string path = AssetDatabase.GUIDToAssetPath(guids[0]);
            SerializedObject so = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath(path)[0]);
            SerializedProperty it = so.GetIterator();
            //���������
            foreach (string k in ShaderFind.C_CustomPostProcessOrders.Keys)
            {
                ShaderFind.C_CustomPostProcessOrders.TryGetValue(k, out List<Type> lst);
                if (lst == null || lst.Count == 0) { continue; }
                InsertCustomDataPostProcess_InjectionPoint(k, lst, it, so);
            }
            //ˢ����Դ
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
        static private void InsertCustomDataPostProcess_InjectionPoint(string k, List<Type> lst, SerializedProperty it, SerializedObject so)
        {
            SerializedProperty prop;
            while (it.NextVisible(true))
            {
                if (it.name == k)
                {
                    List<Type> alst = new List<Type>();
                    for (int i = 0; i < lst.Count; i++)
                    {
                        bool b = false;
                        for (int j = 0; j < it.arraySize; j++)
                        {
                            prop = it.GetArrayElementAtIndex(j);
                            if (prop.boxedValue.ToString().StartsWith(lst[i].FullName))
                            {//����
                                b = true;
                                break;
                            }
                        }
                        if (!b) { alst.Add(lst[i]); /*׷��*/ }
                    }

                    if (alst.Count != 0)
                    {
                        for (int i = 0; i < alst.Count; i++)
                        {
                            int _i = it.arraySize;
                            it.InsertArrayElementAtIndex(_i);
                            prop = it.GetArrayElementAtIndex(_i);
                            prop.boxedValue = alst[i].AssemblyQualifiedName;
                        }
                        so.ApplyModifiedProperties();
                    }

                    break;
                }
            }
        }
        #endregion

    }

}