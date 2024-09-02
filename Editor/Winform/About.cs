using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    public class Desc
    {
        static public string ProjectName { get; set; } = "Graphi Rendering";
        static public string Pipeline { get; set; } = "HDRP";
        static public string GitPath { get; set; } = "https://github.com/qnstd";
    }


    /// <summary>
    /// 关于
    /// <para>作者：强辰</para>
    /// </summary>
    public class About : EditorWindow
    {
        static readonly Vector2 C_Revolution = new Vector2(400, 130);
        static bool IsOpen = false;
        static About Self = null;

        [MenuItem("Help/About Graphi", false, 9999)]
        static public void Run()
        {
            if (IsOpen)
            {
                Cls();
                return;
            }

            About win = (About)Gui.ShowWin<About>("About", C_Revolution, true);
            Gui.WinCenter(win, C_Revolution);

            IsOpen = true;
            Self = win;
        }


        static public void Cls()
        {
            Self.Close();
        }


        // ///////////////////////////////////////////////////////////////////////////

        //Logo纹理
        Texture2D m_t2d;
        //Logo背景
        Texture2D m_t2d2;


        private void OnEnable()
        {
            string f = renderhdrp.Tools.FindexactFile("Editor/Images", "Graphi-Logo.png");
            if (f != null)
                m_t2d = AssetDatabase.LoadAssetAtPath<Texture2D>(f);
            f = renderhdrp.Tools.FindexactFile("Editor/Images", "Graphi-AboutBackground.png");
            if (f != null)
                m_t2d2 = AssetDatabase.LoadAssetAtPath<Texture2D>(f);
        }


        private void OnDisable()
        {
            m_t2d = null;
            m_t2d2 = null;
        }


        private void OnDestroy()
        {
            IsOpen = false;
            Self = null;
        }


        private void OnGUI()
        {
            #region 绘制背景和LOGO
            if (m_t2d2 != null)
                Graphics.DrawTexture(new Rect(0, 0, m_t2d2.width, m_t2d2.height), m_t2d2);
            if (m_t2d != null)
                Graphics.DrawTexture(new Rect(20, 11, m_t2d.width >> 1, m_t2d.height >> 1), m_t2d);
            #endregion


            #region 信息
            Gui.Area(90, 13, 240, 50);
            GUIStyle sty = new GUIStyle("AM MixerHeader") { richText = true };
            Gui.Hor();
            Gui.Label($"{Desc.ProjectName}", sty, Gui.W(165));
            sty.fontSize = 10;
            sty.alignment = TextAnchor.UpperLeft;
            Gui.Label($"<color=#7ef8f1>{Desc.Pipeline}</color>", sty);
            Gui.EndHor();
            Gui.EndArea();

            Gui.Area(90, 45, 300, 50);
            sty = new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 9, contentOffset = new Vector2(0, 0) };
            Gui.Hor();
            Gui.Btn("README", ()=> { OpenMD("", "README"); }, sty, Gui.W(50), Gui.H(13));
            Gui.Btn("LICENSE", ()=> { OpenMD("", "LICENSE"); }, sty, Gui.W(50), Gui.H(13));
            Gui.Btn("DOCUMENTATION", ()=> { OpenMD("Documentation", "graphi_shader_hdrp"); }, sty, Gui.W(100), Gui.H(13));
            Gui.Btn("CHANGELOG", ()=> { OpenMD("", "CHANGELOG"); }, sty, Gui.W(80), Gui.H(13));
            Gui.EndHor();
            Gui.Space(3);
            Gui.Btn($"<color=#ffcc00><b>Git</b></color> - {Desc.GitPath}", ()=> { Application.OpenURL(Desc.GitPath); }, sty, Gui.W(160), Gui.H(15));
            Gui.EndArea();
            #endregion


            #region 快捷操作
            float _h = 28;
            Gui.Area(90, C_Revolution.y - _h - 2, C_Revolution.x, _h);
            Gui.Hor();
            Gui.Btn("Settings",()=> { SettingsService.OpenProjectSettings("Project/Graphi"); }, sty, Gui.W(70), Gui.H(14));
            Gui.Btn("Feedback", ()=> { Mail.Open(); }, sty, Gui.W(70), Gui.H(14));
            Gui.EndHor();
            Gui.EndArea();
            #endregion
        }


        private void OpenMD(string relp, string name)
        {
            EditorUtility.RevealInFinder(renderhdrp.Tools.FindexactFile(relp, $"{name}.md"));
        }

    }
}