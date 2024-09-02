using System;
using System.IO;
using System.Reflection;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
#if UNITY_EDITOR

    /// <summary>
    /// 3D纹理创建
    /// <para>作者：强辰</para>
    /// </summary>
    public class Build3DTexture : EditorWindow
    {
        [MenuItem("Assets/Graphi/Tex/3D")]
        static void CreateTexture3D()
        {
            Gui.ShowWin<Build3DTexture>("Texture3D Create");
        }


        /// <summary>
        /// 3D纹理尺寸
        /// </summary>
        enum T3DSize
        {
            x16 = 16,
            x32 = 32,
            x64 = 64,
            x128 = 128,
        }

        /// <summary>
        /// 3D纹理样式
        /// </summary>
        enum T3DType
        {
            Custom, // 自定义
            ColourCube, // 彩色方块
            ColourCircle, // 彩色球
            GrayGradientCube, // 灰度渐变方块
            GrayGradientCircle, // 灰度渐变球
            ZebraStripesCircle, //斑马线球
            NoiseCircle, // 噪声
            NoiseCircleBlack, // 黑色噪声
        }

        private Vector2 m_V2 = Vector2.zero;
        private bool m_FoldoutSaveSet = true;
        private string m_SavePath = "Assets/";
        private string m_Filename = "T3D";
        private bool m_FoldoutTexSet = true;
        private TextureFormat m_Format = TextureFormat.RGBA32;
        private TextureWrapMode m_WrapMode = TextureWrapMode.Clamp;
        private FilterMode m_FilterMode = FilterMode.Bilinear;
        private T3DSize m_Size = T3DSize.x16;
        private float m_Alpha = 0.1f;
        const float m_AlphaMin = 0.001f;
        const float m_AlphaMax = 1.0f;
        private T3DType m_Type = T3DType.ColourCube;
        private string m_CustomUsing = "using System;\nusing UnityEngine;";
        private string m_CustomMethodName = "Run";
        private string m_CustomMethodContent =
            "// x,y,z：Each axial dimension of the 3D texture， size：Size， inverseResolution：1.0/(Size - 1) \n\n" +
            "public UnityEngine.Color Run( int x,  int y,  int z,  float inverseResolution,  int size )\n" +
            "{\n" +
            "   return new UnityEngine.Color( 1,1,1,1 );\n" +
            "}";
        Texture3D m_GenTex = null;
        UnityEditor.Editor m_T3DPreview = null;


        GUIStyle lightStyle;
        GUIStyle btnStyle1;


        private void OnDisable()
        {
            if (m_T3DPreview != null)
            {
                DestroyImmediate(m_T3DPreview);
                m_T3DPreview = null;
            }
            m_GenTex = null;
        }


        private void OnGUI()
        {
            if (lightStyle == null)
                lightStyle = new GUIStyle("LODSliderText") { richText = true };
            if (btnStyle1 == null)
                btnStyle1 = new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 10, alignment = TextAnchor.MiddleCenter };


            Gui.Space(10);
            m_V2 = Gui.Scroll(m_V2);

            // 效果图
            Gui.Space(8);
            GUILayout.BeginArea(new Rect(0, 0, EditorGUIUtility.currentViewWidth, 300), new GUIContent("Preview"), EditorStyles.helpBox);
            if (m_T3DPreview != null && m_GenTex != null)
            {
                Gui.Space(20);
                m_T3DPreview.OnInteractivePreviewGUI(GUILayoutUtility.GetRect(256, 256), lightStyle);
            }
            GUILayout.EndArea();

            // 操作元素
            Gui.Space(315);
            m_FoldoutSaveSet = EditorGUILayout.Foldout(m_FoldoutSaveSet, new GUIContent("Save"), true);
            if (m_FoldoutSaveSet)
            {
                Gui.Space(5);
                Gui.IndentLevelAdd(2);
                Gui.Vertical("box");
                Gui.Space(5);
                m_SavePath = EditorGUILayout.TextField(new GUIContent("Path"), m_SavePath);
                Gui.Space(5);
                m_Filename = EditorGUILayout.TextField(new GUIContent("Filename"), m_Filename);
                Gui.Space(5);
                Gui.EndVertical();
                Gui.IndentLevelSub(2);
            }
            Gui.Space(20);
            m_FoldoutTexSet = EditorGUILayout.Foldout(m_FoldoutTexSet, new GUIContent("Texture"), true);
            if (m_FoldoutTexSet)
            {
                Gui.Space(5);
                Gui.IndentLevelAdd(2);
                Gui.Vertical("box");
                Gui.Space(5);
                m_Size = (T3DSize)EditorGUILayout.EnumPopup(new GUIContent("Size"), m_Size);
                Gui.Space(5);
                m_Format = (TextureFormat)EditorGUILayout.EnumPopup(new GUIContent("Format"), m_Format);
                Gui.Space(5);
                m_WrapMode = (TextureWrapMode)EditorGUILayout.EnumPopup(new GUIContent("Warp"), m_WrapMode);
                Gui.Space(5);
                m_FilterMode = (FilterMode)EditorGUILayout.EnumPopup(new GUIContent("Filter"), m_FilterMode);
                Gui.Space(5);
                m_Alpha = EditorGUILayout.Slider(new GUIContent("Alpha multiple"), m_Alpha, m_AlphaMin, m_AlphaMax);
                Gui.Space(5);
                m_Type = (T3DType)EditorGUILayout.EnumPopup(new GUIContent("Style"), m_Type);

                //EditorGUI.BeginDisabledGroup(!(m_Type == T3DType.Custom));
                if (m_Type == T3DType.Custom)
                {
                    Gui.IndentLevelAdd(2);
                    Gui.Space(15);
                    Gui.Hor();
                    Gui.Label("<color=#e8df7e>* Recommended for technical personnels</color>", lightStyle);
                    Gui.Space(1);
                    if (GUILayout.Button("Open", btnStyle1, Gui.W(70), Gui.H(16))) { Open(); }
                    if (GUILayout.Button("Save", btnStyle1, Gui.W(70), Gui.H(16))) { Save(); }
                    Gui.EndHor();
                    Gui.Space(7);
                    Gui.Label("using");
                    m_CustomUsing = EditorGUILayout.TextArea(m_CustomUsing, Gui.H(100));
                    Gui.Space(3);
                    m_CustomMethodName = EditorGUILayout.TextField(new GUIContent("Function Name"), m_CustomMethodName);
                    Gui.Space(3);
                    Gui.Label("Function Body");
                    m_CustomMethodContent = EditorGUILayout.TextArea(m_CustomMethodContent, Gui.H(200));
                    Gui.IndentLevelSub(2);
                }
                //EditorGUI.EndDisabledGroup();
                Gui.Space(5);
                Gui.EndVertical();
                Gui.IndentLevelSub(2);
            }

            Gui.Space(2);
            Gui.Hor();
            Gui.Space(1);
            if (GUILayout.Button("Build", btnStyle1, Gui.W(110), Gui.H(30)))
            {
                Gen();
            }
            Gui.EndHor();


            // 底部留出的间距
            Gui.Space(20);
            Gui.EndScroll();
        }


        #region 保存、打开自定义3D纹理脚本文件
        const string C_FilePostfix = "3dtex";
        const string C_FileDefaultName = "Custom3DTexCode";
        const string C_SeqSign = "|kv|";
        const string C_SeqSign2 = "|3dtex|";
        const string C_FileKeyvalue = "{0}" + C_SeqSign + "{1}";

        private void Save()
        {
            string p = EditorUtility.SaveFilePanelInProject("Save", C_FileDefaultName, C_FilePostfix, "");
            if (string.IsNullOrEmpty(p)) { return; }
            StringBuilder sb = new StringBuilder();
            sb
                .Append(string.Format(C_FileKeyvalue, "m_CustomUsing", m_CustomUsing))
                .Append(C_SeqSign2)
                .Append(string.Format(C_FileKeyvalue, "m_CustomMethodName", m_CustomMethodName))
                .Append(C_SeqSign2)
                .Append(string.Format(C_FileKeyvalue, "m_CustomMethodContent", m_CustomMethodContent))
                ;
            File.WriteAllBytes(p, Encoding.UTF8.GetBytes(sb.ToString()));
            AssetDatabase.Refresh();
        }
        private void Open()
        {
            string p = EditorUtility.OpenFilePanelWithFilters("Open", "", new string[] { C_FilePostfix, C_FilePostfix });
            if (string.IsNullOrEmpty(p)) { return; }

            // 设置焦点消失，防止反射对变量赋值后，界面无法及时刷新
            GUIUtility.keyboardControl = 0;

            // 读取并赋值
            string[] infos = Encoding.UTF8.GetString(File.ReadAllBytes(p)).Split(C_SeqSign2);
            string[] childinfos;
            foreach (string s in infos)
            {
                childinfos = s.Split(C_SeqSign);
                FieldInfo fi = GetType().GetField(childinfos[0], BindingFlags.NonPublic | BindingFlags.Instance);
                fi.SetValue(this, childinfos[1]);
            }
        }
        #endregion


        private bool IsOK(ref string errmsg)
        {
            if (string.IsNullOrEmpty(m_Filename) || string.IsNullOrEmpty(m_SavePath)) { errmsg = "The save path or file name is invalid."; return false; }
            if (!Directory.Exists(m_SavePath)) { errmsg = "Path is not exist."; return false; }
            if ((int)m_Size % 4 != 0) { errmsg = "Size Error! should be divisible by 4."; return false; }
            return true;
        }


        private void Gen()
        {
            string err = null;
            if (!IsOK(ref err))
            {
                Gui.Dialog(err);
                return;
            }

            int size = (int)m_Size;
            Texture3D t3d = new Texture3D(size, size, size, m_Format, false);
            t3d.wrapMode = m_WrapMode;
            t3d.filterMode = m_FilterMode;

            object scriptInst = null;
            MethodInfo scriptMethod = null;
            if (T3DType.Custom == m_Type)
            {
                scriptInst = Eval.Instance.CompileAndGetInstance(m_CustomMethodContent, m_CustomUsing);
                scriptMethod = Eval.Instance.GetMethod(scriptInst, m_CustomMethodName);
            }

            Color32[] colors = new Color32[size * size * size];
            float inverseResolution = 1.0f / (size - 1.0f);
            for (int z = 0; z < size; z++)
            {
                int zOffset = z * size * size;
                for (int y = 0; y < size; y++)
                {
                    int yOffset = y * size;
                    for (int x = 0; x < size; x++)
                    {
                        Color c = new Color(1, 1, 1, 1);
                        switch (m_Type)
                        {
                            case T3DType.ColourCube:
                                c = Draw_ColourCube(x, y, z, inverseResolution, size);
                                break;
                            case T3DType.ColourCircle:
                                c = Draw_ColourCircle(x, y, z, inverseResolution, size);
                                break;
                            case T3DType.GrayGradientCube:
                                c = Draw_GrayGradientCube(x, y, z, inverseResolution, size);
                                break;
                            case T3DType.GrayGradientCircle:
                                c = Draw_GrayGradientCircle(x, y, z, inverseResolution, size);
                                break;
                            case T3DType.ZebraStripesCircle:
                                c = Draw_ZebraStripesCircle(x, y, z, inverseResolution, size);
                                break;
                            case T3DType.NoiseCircle:
                                c = Draw_Noise(x, y, z, inverseResolution, size);
                                break;
                            case T3DType.NoiseCircleBlack:
                                c = Draw_Noise_Black(x, y, z, inverseResolution, size);
                                break;
                            case T3DType.Custom:
                                if (scriptInst != null && scriptMethod != null)
                                {
                                    c = (Color)Eval.Instance.Excute
                                    (
                                        scriptMethod, scriptInst,
                                        x, y, z, inverseResolution, size
                                    );
                                }
                                break;
                        }

                        c.a *= m_Alpha;
                        colors[x + yOffset + zOffset] = c;
                    }
                }
            }

            t3d.SetPixels32(colors);
            t3d.Apply();
            string p = Path.Combine(m_SavePath, m_Filename + ".asset");
            AssetDatabase.CreateAsset(t3d, p);
            m_GenTex = AssetDatabase.LoadAssetAtPath<Texture3D>(p);
            m_T3DPreview = UnityEditor.Editor.CreateEditor(m_GenTex);
            Gui.Dialog("Build Finish!");
        }



        #region 默认提供的3D纹理样式
        private float GetRadius(int x, int y, int z, int size)
        {
            float r = Mathf.Sqrt
                        (
                            Mathf.Pow(2f * (x - 0.5f * size) / size, 2) +
                            Mathf.Pow(2f * (y - 0.5f * size) / size, 2) +
                            Mathf.Pow(2f * (z - 0.5f * size) / size, 2)
                         );
            r = (r <= 1f) ? 1f : 0f;
            return r;
        }
        private float CalGrayGradient(int v, float inverseResolution)
        {
            float val = Mathf.Pow(v * inverseResolution, 3);
            val += 0.2f;
            val = (val >= 1.0f) ? 1.0f : val;
            return val;
        }

        private Color Draw_ColourCube(int x, int y, int z, float inverseResolution, int size)
        {
            return new Color(x * inverseResolution, y * inverseResolution, z * inverseResolution, 1.0f);
        }
        private Color Draw_GrayGradientCube(int x, int y, int z, float inverseResolution, int size)
        {
            float val = CalGrayGradient(y, inverseResolution);
            return new Color(val, val, val, 1.0f);
        }
        private Color Draw_ColourCircle(int x, int y, int z, float inverseResolution, int size)
        {
            return new Color(x * inverseResolution, y * inverseResolution, z * inverseResolution, GetRadius(x, y, z, size));
        }
        private Color Draw_GrayGradientCircle(int x, int y, int z, float inverseResolution, int size)
        {
            float val = CalGrayGradient(y, inverseResolution);
            return new Color(val, val, val, GetRadius(x, y, z, size));
        }
        private Color Draw_Noise_Black(int x, int y, int z, float inverseResolution, int size)
        {
            double val = Math.Pow(Mathf.Sin(x * y * z), 1000);
            val = Math.Abs(val - Math.Truncate(val));
            float val_ = (float)val;
            return new Color(val_, val_, val_, GetRadius(x, y, z, size));
        }
        private Color Draw_Noise(int x, int y, int z, float inverseResolution, int size)
        {
            double val = Mathf.Sin(x * y * z) * 1000;
            val = Math.Abs(val - Math.Truncate(val));
            val = Mathf.Pow((float)val, 3);
            float val_ = (float)val;
            return new Color(val_, val_, val_, GetRadius(x, y, z, size));
        }
        private Color Draw_ZebraStripesCircle(int x, int y, int z, float inverseResolution, int size)
        {
            double val = (Mathf.Sin(x + y + z) * 1000);
            val = Math.Abs(val - Math.Truncate(val));
            float val_ = (float)val;
            return new Color(val_, val_, val_, GetRadius(x, y, z, size));
        }
        #endregion
    }
#endif
}