using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ���ɷ�����ͼ
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class BuildNormalTexture : EditorWindow
    {
        #region ö��
        /// <summary>
        /// ������������ļ�����
        /// <para>���ߣ�ǿ��</para>
        /// </summary>
        enum NormalTexFileType
        {
            PNG,
            TGA,
        }

        /// <summary>
        /// ��������X��Y��ת����
        /// <para>���ߣ�ǿ��</para>
        /// </summary>
        enum InvertFlag
        {
            On = -1,
            Off = 1
        }


        /// <summary>
        /// ���ɷ��ߵ��㷨����
        /// <para>���ߣ�ǿ��</para>
        /// </summary>
        enum Flgorithm
        {
            Sobel = 0
            //Scharr
        }
        #endregion


        #region ��������

        static Vector2 c_winsize = new Vector2(580, 700);
        static Vector2 c_btnsize = new Vector2(130, 22);
        const int c_comsize = 500;
        const int c_size = 240;
        const float c_minblur = 0.0f;
        const float c_maxblur = 5.0f;
        const int c_blurIterMin = 1;
        const int c_blurIterMax = 4;
        #endregion


        #region ��������

        Vector2 m_scrollV2 = Vector2.zero;
        Vector2 m_scrollV2_2 = Vector2.zero;
        Material m_blurMat = null;
        Material m_transferNormalMat = null;

        const string m_srcinfoStr = "Name: <color=#ffffffff>{0}</color>\nCompress: <color=#fce8acff>{1}</color>\nSize: <color=#acfcd7ff>{2} * {3}</color>";
        string m_srcinfo = "";

        Texture2D m_normal = null;
        Texture2D m_src = null;

        Flgorithm m_flgorithm = Flgorithm.Sobel;
        float m_strength = 0.1f;
        float m_level = 2;
        TextureWrapMode m_wrapMode = TextureWrapMode.Repeat;
        FilterMode m_filterMode = FilterMode.Bilinear;
        InvertFlag m_R = InvertFlag.On;
        InvertFlag m_G = InvertFlag.On;
        float m_blur = c_minblur;
        int m_blurIter = c_blurIterMin;
        float m_rgScale = 0.25f;

        NormalTexFileType m_normalTexFileType = NormalTexFileType.PNG;
        string m_filenme = "Tex_N";
        string m_filepath = "Assets";
        bool m_mipmap = true;

        readonly List<string> lst = new List<string>();
        int m_dirty = 0;

        #endregion


        [MenuItem("Assets/Create/NormalTexture")]
        static private void Run()
        {
            Gui.ShowWin<BuildNormalTexture>("NormalTex Build", c_winsize);
        }


        private void OnEnable()
        {
            //��ȡ����������ʱ��Ҫ��Shader�ű�
            m_transferNormalMat = CoreUtils.CreateEngineMaterial("Hidden/Graphi/Tool/NormalTextureBuild");
            m_blurMat = CoreUtils.CreateEngineMaterial("Hidden/Graphi/Tool/NormalTextureBlur");
        }


        private void OnGUI()
        {
            //�߶�ͼ
            Gui.Hor();
            GUILayout.BeginArea(new Rect(20, 0, 330, 330));
            Gui.Space(12);
            Gui.Label("Albedo/High Tex");
            Gui.Space(3);
            Gui.IndentLevelAdd();
            m_src = (Texture2D)EditorGUILayout.ObjectField(m_src, typeof(Texture2D), false, GUILayout.Height(c_size), GUILayout.Width(c_size));
            if (m_src != null)
                m_srcinfo = string.Format(m_srcinfoStr, m_src.name, m_src.format, m_src.width, m_src.height);
            else
                m_srcinfo = "";
            Gui.Disabled(true);
            GUIStyle sty = new GUIStyle("WhiteMiniLabel");
            sty.richText = true;
            sty.fontSize = 10;
            m_srcinfo = EditorGUILayout.TextField(m_srcinfo, sty, GUILayout.Height(70));
            Gui.EndDisabled();
            Gui.IndentLevelSub();
            GUILayout.EndArea();

            //����ͼ
            GUILayout.BeginArea(new Rect(300, 0, 330, 330));
            Gui.Space(12);
            Gui.Label("Normal Tex");
            Gui.Space(3);
            Gui.IndentLevelAdd();
            //Gui.Disabled(true);
            m_normal = (Texture2D)EditorGUILayout.ObjectField(m_normal, typeof(Texture2D), false, GUILayout.Height(c_size), GUILayout.Width(c_size));
            //Gui.EndDisabled();
            Gui.Label("* Double click to see", sty);
            Gui.IndentLevelSub();
            GUILayout.EndArea();
            Gui.EndHor();

            //�������ɵĲ�������
            GUILayout.BeginArea(new Rect(13, 338, c_winsize.x - 25, 177), "Setting", EditorStyles.helpBox);
            Gui.IndentLevelAdd(2);
            Gui.Space(21);
            m_scrollV2 = EditorGUILayout.BeginScrollView(m_scrollV2, GUILayout.Height(140));
            m_flgorithm = (Flgorithm)EditorGUILayout.EnumPopup("Fucntion", m_flgorithm, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_strength = EditorGUILayout.FloatField("Force", m_strength, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_level = EditorGUILayout.FloatField("Offset", m_level, GUILayout.Width(c_comsize));
            Gui.Space(2);
            Gui.Hor();
            EditorGUILayout.LabelField("Inverse", GUILayout.Width(120));
            Gui.Vertical();
            m_R = (InvertFlag)EditorGUILayout.EnumPopup("R channel", m_R, GUILayout.Width(190));
            m_G = (InvertFlag)EditorGUILayout.EnumPopup("G channel", m_G, GUILayout.Width(190));
            Gui.EndVertical();
            Gui.EndHor();
            Gui.Space(2);
            m_rgScale = EditorGUILayout.Slider("R/G Scale", m_rgScale, 0, 1, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_blurIter = EditorGUILayout.IntSlider("Iterations", m_blurIter, c_blurIterMin, c_blurIterMax, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_blur = EditorGUILayout.Slider("Blur Force", m_blur, c_minblur, c_maxblur, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_wrapMode = (TextureWrapMode)EditorGUILayout.EnumPopup("Wrap", m_wrapMode, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_filterMode = (FilterMode)EditorGUILayout.EnumPopup("Filter", m_filterMode, GUILayout.Width(c_comsize));
            EditorGUILayout.EndScrollView();
            Gui.IndentLevelSub(2);
            GUILayout.EndArea();

            //��������
            GUILayout.BeginArea(new Rect(13, 530, c_winsize.x - 25, 155), "Save", EditorStyles.helpBox);
            Gui.IndentLevelAdd(2);
            Gui.Space(30);
            m_scrollV2_2 = EditorGUILayout.BeginScrollView(m_scrollV2_2, GUILayout.Height(68));
            m_normalTexFileType = (NormalTexFileType)EditorGUILayout.EnumPopup("Type", m_normalTexFileType, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_filenme = EditorGUILayout.TextField("Filename", m_filenme, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_filepath = EditorGUILayout.TextField("Path", m_filepath, GUILayout.Width(c_comsize));
            Gui.Space(2);
            m_mipmap = EditorGUILayout.Toggle("Mipmap", m_mipmap, GUILayout.Width(c_comsize));
            EditorGUILayout.EndScrollView();
            Gui.IndentLevelSub(2);
            GUILayout.BeginArea(new Rect((c_winsize.x - c_btnsize.x) * 0.5f, 142 - c_btnsize.y, c_btnsize.x, c_btnsize.y));
            if (GUILayout.Button("Save", GUILayout.Height(c_btnsize.y), GUILayout.Width(c_btnsize.x)))
            {
                SaveNormalTex();
            }
            GUILayout.EndArea();
            GUILayout.EndArea();


            if (Dirty())
            {//��Ҫ���¼��㲢ˢ�·���ͼ
                GenNormalTex(false);
            }
        }


        /// <summary>
        /// ���ò�ˢ�·���ͼ
        /// </summary>
        /// <returns></returns>
        private bool Dirty()
        {
            if (m_src == null)
            {
                if (m_normal != null)
                {
                    DestroyImmediate(m_normal);
                    m_normal = null;
                }
                m_dirty = 0;
                return false;
            }

            //��ϲ�������hashֵ����������һ�ε�hashֵ���ȶԣ����и���
            lst.Clear();
            if (m_src == null)
                lst.Add("Null");
            else
                lst.Add(m_src.width + "," + m_src.height);

            lst.Add(((int)m_flgorithm).ToString());
            lst.Add(m_strength.ToString());
            lst.Add(m_level.ToString());
            lst.Add(m_blurIter.ToString());
            lst.Add(m_blur.ToString());
            lst.Add(((int)m_R).ToString());
            lst.Add(((int)m_G).ToString());
            lst.Add(((int)m_wrapMode).ToString());
            lst.Add(((int)m_filterMode).ToString());
            lst.Add(m_rgScale.ToString());
            //����

            int dirty = string.Join("|", lst).GetHashCode();
            if (m_dirty != dirty)
            {
                m_dirty = dirty;
                return true;
            }
            return false;
        }


        /// <summary>
        /// ģ������
        /// <para>Ϊ��ʹ�ϴ�ߴ���������磺2048*2048���ڲ���ʱ�ܼӿ촦���ٶȣ���ԭ����C#���߼���ֲ��Shader��ִ�У��������ļ����CPU��ֲ��GPU��</para>
        /// </summary>
        /// <param name="tex"></param>
        /// <param name="W"></param>
        /// <param name="H"></param>
        /// <returns></returns>
        private Texture2D Blur(ref Texture2D tex, int W, int H)
        {
            //����ģ������
            RenderTexture Temp1 = RenderTexture.GetTemporary(W, H, 0);
            RenderTexture Temp2 = RenderTexture.GetTemporary(W, H, 0);
            Graphics.Blit(tex, Temp1);

            for (int i = 0; i < m_blurIter; i++)
            {
                //���ò���
                m_blurMat.SetFloat("_Blur", m_blur * (i + 1));

                m_blurMat.SetTexture("_BlitTexture", Temp1);
                Graphics.Blit(Temp1, Temp2, m_blurMat, 0); //y
                m_blurMat.SetTexture("_BlitTexture", Temp2);
                Graphics.Blit(Temp2, Temp1, m_blurMat, 1); //x
            }

            //��ȡģ��������ϵ�������Ϣ
            RenderTexture curRT = RenderTexture.active;
            RenderTexture.active = Temp1;
            Texture2D blurTex = new Texture2D(W, H, TextureFormat.RGBA32, false);
            blurTex.ReadPixels(new Rect(0, 0, W, H), 0, 0);
            blurTex.Apply();
            RenderTexture.active = curRT;

            //�ͷ���ʱ����
            DestroyImmediate(tex);
            RenderTexture.ReleaseTemporary(Temp1);
            RenderTexture.ReleaseTemporary(Temp2);

            return blurTex;
        }


        /// <summary>
        /// ���㷨��
        /// <para>Ϊ��ʹ�ϴ�ߴ���������磺2048*2048���ڲ���ʱ�ܼӿ촦���ٶȣ���ԭ����C#���߼���ֲ��Shader��ִ�У��������ļ����CPU��ֲ��GPU��</para>
        /// </summary>
        /// <param name="tex"></param>
        /// <param name="W"></param>
        /// <param name="H"></param>
        private void TransferN(out Texture2D tex, int W, int H)
        {
            // ����
            RenderTexture nRT = RenderTexture.GetTemporary(W, H, 0);
            m_transferNormalMat.SetFloat("_Strength", m_strength);
            m_transferNormalMat.SetFloat("_Level", m_level);
            m_transferNormalMat.SetVector("_Invert", new Vector4((int)m_R, (int)m_G, 0, 0));
            m_transferNormalMat.SetInt("_Flgorithm", (int)m_flgorithm);
            m_transferNormalMat.SetTexture("_BlitTexture", m_src);
            m_transferNormalMat.SetFloat("_RGScale", m_rgScale);
            Graphics.Blit(m_src, nRT, m_transferNormalMat, 0);

            // ����
            tex = new Texture2D(W, H, TextureFormat.RGBA32, false);
            tex.wrapMode = m_wrapMode;
            tex.filterMode = m_filterMode;
            RenderTexture cur = RenderTexture.active;
            RenderTexture.active = nRT;
            tex.ReadPixels(new Rect(0, 0, W, H), 0, 0);
            tex.Apply();
            RenderTexture.active = cur;
            RenderTexture.ReleaseTemporary(nRT);
        }


        /// <summary>
        /// ���ɷ�������
        /// </summary>
        /// <param name="showDialog"></param>
        private void GenNormalTex(bool showDialog = true)
        {
            if (m_src == null)
            {
                if (showDialog)
                    Gui.Dialog("Texture missing", "Warnning");
                else
                    Debug.LogError("Texture missing");
                return;
            }

            try
            { m_src.GetPixel(0, 0); }
            catch (Exception)
            {
                if (showDialog)
                    Gui.Dialog("Texture's Read/Write value must be true.", "Warnning");
                else
                    Debug.LogError("Texture's Read/Write value must be true.");

                if (m_normal != null)
                    DestroyImmediate(m_normal);
                m_src = null;
                m_normal = null;
                m_dirty = 0;
                return;
            }


            //���߼���
            int W = m_src.width;
            int H = m_src.height;
            TransferN(out Texture2D tex, W, H);

            //�Է�������ģ������
            if (m_blur != 0)
                m_normal = Blur(ref tex, W, H);
            else
                m_normal = tex;

            Selection.activeObject = m_normal;
        }


        /// <summary>
        /// ����
        /// </summary>
        private void SaveNormalTex()
        {
            if (m_normal == null)
            {
                Gui.Dialog("Texture missing��", "Warnning");
                return;
            }
            if (string.IsNullOrEmpty(m_filenme) || string.IsNullOrEmpty(m_filepath))
            {
                Gui.Dialog("Texture missing��", "Warnning");
                return;
            }

            string p;
            try
            {
                byte[] bytes = null;
                string typ = "";
                switch (m_normalTexFileType)
                {
                    case NormalTexFileType.PNG:
                        bytes = m_normal.EncodeToPNG();
                        typ = ".png";
                        break;
                    case NormalTexFileType.TGA:
                        bytes = m_normal.EncodeToTGA();
                        typ = ".tga";
                        break;
                }
                p = Path.Combine(m_filepath, m_filenme + typ);
                p = p.Replace("\\", "/");
                using (FileStream fs = new FileStream(p, FileMode.OpenOrCreate))
                {
                    fs.Write(bytes, 0, bytes.Length);
                }
                AssetDatabase.Refresh();
            }
            catch (Exception e)
            {
                Gui.Dialog(e.Message, "Warnning");
                return;
            }

            //�޸����ɵ�����ͼ����
            TextureImporter texImport = (TextureImporter)AssetImporter.GetAtPath(p);
            texImport.mipmapEnabled = m_mipmap;
            texImport.textureType = TextureImporterType.NormalMap;
            texImport.isReadable = false;

            Gui.Dialog("Save Finish!");
        }

    }
}