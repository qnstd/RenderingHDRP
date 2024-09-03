using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 关于
    /// <para>作者：强辰</para>
    /// </summary>
    public class About : EditorWindow
    {
        static public string ProjectName { get; set; } = "Graphi Rendering";
        static public string Pipeline { get; set; } = "HDRP";
        static public string GitPath { get; set; } = "https://github.com/qnstd";


        static readonly Vector2 C_Revolution = new Vector2(400, 350);
        static bool IsOpen = false;
        static About Self = null;

        [MenuItem("Window/Rendering/Graphi Rendering HDRP")]
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



        //Logo纹理
        Texture2D m_t2d;
        //Logo背景
        Texture2D m_t2d2;

        string m_Email;
        string m_Title = "";
        string m_Content;

        GUIStyle m_BtnStyle = null;
        GUIStyle m_LabelStyle = null;
        GUIStyle m_TextStyle = null;
        void InitStyle()
        {
            if (m_BtnStyle == null) { m_BtnStyle = new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 9 }; }
            if (m_LabelStyle == null) { m_LabelStyle = new GUIStyle("MiniLabel") { richText = true, fontSize = 11, alignment = TextAnchor.MiddleRight }; }
            if (m_TextStyle == null) { m_TextStyle = new GUIStyle("HelpBox") { richText = true, wordWrap = true, fontSize = 11 }; }
        }


        private void OnEnable()
        {
            string f = ProjectUtils.FindexactFile("Editor/Images", "Graphi-Logo.png");
            if (f != null)
                m_t2d = AssetDatabase.LoadAssetAtPath<Texture2D>(f);
            f = ProjectUtils.FindexactFile("Editor/Images", "Graphi-AboutBackground.png");
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
            InitStyle();

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
            Gui.Label($"{ProjectName}", sty, Gui.W(165));
            sty.fontSize = 10;
            sty.alignment = TextAnchor.UpperLeft;
            Gui.Label($"<color=#7ef8f1>{Pipeline}</color>", sty);
            Gui.EndHor();
            Gui.EndArea();

            Gui.Area(90, 45, 300, 50);
            Gui.Hor();
            Gui.Btn("readme", () => { OpenMD("", "README"); }, m_BtnStyle, Gui.W(50), Gui.H(13));
            Gui.Btn("license", () => { OpenMD("", "LICENSE"); }, m_BtnStyle, Gui.W(50), Gui.H(13));
            Gui.Btn("documentation", () => { OpenMD("Documentation", "graphi_shader_hdrp"); }, m_BtnStyle, Gui.W(100), Gui.H(13));
            Gui.Btn("log", () => { OpenMD("", "CHANGELOG"); }, m_BtnStyle, Gui.W(50), Gui.H(13));
            Gui.EndHor();
            Gui.Space(3);
            Gui.Btn($"<color=#ffcc00><b>Git</b></color> - {GitPath}", () => { Application.OpenURL(GitPath); }, m_BtnStyle, Gui.W(160), Gui.H(15));
            Gui.EndArea();
            #endregion


            #region 快捷操作
            Gui.Area(90, 95, C_Revolution.x, 28);
            Gui.Hor();
            Gui.Btn("Settings", () => { SettingsService.OpenProjectSettings("Project/Graphi"); }, m_BtnStyle, Gui.W(70), Gui.H(20));
            Gui.EndHor();
            Gui.EndArea();
            #endregion


            #region 邮件
            Gui.Area(0, 135, C_Revolution.x, C_Revolution.y - 135);
            Gui.Vertical("helpbox");
            Gui.Label("<color=#ffcc00><b>Contact Us</b></color>", sty);
            Gui.Space(5);
            Gui.Hor();
            Gui.Label("<color=#999999>Your Email: </color>", m_LabelStyle, 85);
            m_Email = EditorGUILayout.TextField(m_Email, m_TextStyle);
            Gui.EndHor();

            Gui.Space(5);
            Gui.Hor();
            Gui.Label("<color=#999999>Theme: </color>", m_LabelStyle, 85);
            m_Title = EditorGUILayout.TextField(m_Title, m_TextStyle);
            Gui.EndHor();

            Gui.Space(5);
            Gui.Hor();
            Gui.Label("<color=#999999>Description: </color>", m_LabelStyle, 85);
            m_Content = EditorGUILayout.TextArea(m_Content, m_TextStyle, Gui.H(100));
            Gui.EndHor();

            Gui.Space(5);
            Gui.Hor();
            GUILayout.FlexibleSpace();
            Gui.Btn("Send", () => { SendMail(); }, m_BtnStyle, Gui.W(60), Gui.H(20));
            Gui.EndHor();
            Gui.EndVertical();
            Gui.EndArea();
            #endregion
        }



        /// <summary>
        /// 打开相关文档
        /// </summary>
        /// <param name="relp"></param>
        /// <param name="name"></param>
        private void OpenMD(string relp, string name)
        {
            EditorUtility.RevealInFinder(ProjectUtils.FindexactFile(relp, $"{name}.md"));
        }



        /// <summary>
        /// 发送邮件
        /// </summary>
        private void SendMail()
        {
            if (string.IsNullOrEmpty(m_Email) || string.IsNullOrEmpty(m_Content) || string.IsNullOrEmpty(m_Title))
            {
                Gui.Dialog("Please fill in the email information correctly.");
                return;
            }

            Regex r = new Regex("^\\s*([A-Za-z0-9_-]+(\\.\\w+)*@(\\w+\\.)+\\w{2,5})\\s*$");
            if (!r.IsMatch(m_Email))
            {
                Gui.Dialog("email is invalid.");
                return;
            }

            Close();
            MailUtils.Send(m_Email, m_Title, m_Content, (e) =>
            {
                if (e == null) { return; }
                if (e.Error != null)
                    Gui.Dialog("Send Failed! \n\nReason：" + e.Error.Message);
                else
                    Gui.Dialog("Email sent successfully! Thank you for your feedback.");
            });
        }

    }
}