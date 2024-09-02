using System.ComponentModel;
using System.Net.Mail;
using System.Net;
using System.Text;
using System;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 邮件窗体
    /// <para>作者：强辰</para>
    /// </summary>
    public class Mail : EditorWindow
    {
        static readonly Vector2 size = new Vector2(450, 280);

        static public void Open()
        {
            Gui.ShowWin<Mail>("Usage Feedback", size, true);
        }


        string m_Email;
        string m_Title = "problems and suggestions for improvement";
        string m_Content;


        GUIStyle m_BtnStyle = null;
        GUIStyle m_LabelStyle = null;
        GUIStyle m_TextStyle = null;
        void InitStyle()
        {
            if (m_BtnStyle == null) { m_BtnStyle = new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 10 }; }
            if (m_LabelStyle == null) { m_LabelStyle = new GUIStyle("MiniLabel") { richText = true, fontSize = 11, alignment = TextAnchor.MiddleRight }; }
            if (m_TextStyle == null) { m_TextStyle = new GUIStyle("HelpBox") { richText = true, wordWrap = true, fontSize = 11 }; }
        }


        private void OnGUI()
        {
            InitStyle();

            Gui.Space(15);
            Gui.Hor();
            Gui.Label("<color=#999999>Email: </color>", m_LabelStyle, 60);
            Color cc = GUI.contentColor;
            GUI.contentColor = Color.yellow;
            m_Email = EditorGUILayout.TextField(m_Email, m_TextStyle);
            GUI.contentColor = cc;
            Gui.EndHor();

            Gui.Space(13);
            Gui.Hor();
            Gui.Label("<color=#999999>Theme: </color>", m_LabelStyle, 60);
            m_Title = EditorGUILayout.TextField(m_Title, m_TextStyle);
            Gui.EndHor();

            Gui.Space(4);
            Gui.Hor();
            Gui.Label("<color=#999999>Desc: </color>", m_LabelStyle, 60);
            m_Content = EditorGUILayout.TextArea(m_Content, m_TextStyle, Gui.H(150));
            Gui.EndHor();

            Gui.Area((size.x - 80) * 0.5f, size.y - 36, 80, 23);
            //Color c = GUI.backgroundColor;
            //GUI.backgroundColor = Color.green;
            Gui.Btn("Send", () => { Send(); }, m_BtnStyle, Gui.H(20));
            //GUI.backgroundColor = c;
            Gui.EndArea();
        }


        private void Send()
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
            MailTool.Send(m_Email, m_Title, m_Content, (e) =>
            {
                if (e == null) { return; }
                if (e.Error != null)
                    Gui.Dialog("Send Failed! \n\nReason：" + e.Error.Message);
                else
                    Gui.Dialog("Email sent successfully! Thank you for your feedback.");
            });
        }
    }



    /// <summary>
    /// 邮件工具
    /// <para>作者：强辰</para>
    /// </summary>
    public class MailTool
    {
        #region 配置
        const string host = "smtp.qq.com"; // SMTP邮件服务地址
        const int port = 587;  // 服务端口
        const string sender = "3186979926@qq.com"; // 发送邮件所用的邮箱
        const string password = "ermnnjjcotnmdhbh"; //发送的密码（第三方授权密码）
        const string recieve = "qchen227@outlook.com"; // 接受邮件的邮箱
        #endregion

        const string info = "Email come from: {0}\n\n" + "Description: \n{1}";


        static MailMessage m_Messgae;
        static SmtpClient m_Smtpclient;


        /// <summary>
        /// 发送邮件
        /// </summary>
        /// <param name="email">邮件</param>
        /// <param name="title">主题</param>
        /// <param name="content">内容</param>
        /// <param name="callback">回调</param>
        static public void Send(string email, string title, string content, Action<AsyncCompletedEventArgs> callback = null)
        {
            Dispose();


            m_Messgae = new MailMessage()
            {
                From = new MailAddress(sender),
                Subject = title,
                Body = string.Format(info, email, content),
                SubjectEncoding = Encoding.UTF8,
                BodyEncoding = Encoding.UTF8,
                IsBodyHtml = false
            };

            m_Smtpclient = new SmtpClient()
            {
                Host = host,
                Port = port,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(sender, password),
                EnableSsl = false,
                DeliveryMethod = SmtpDeliveryMethod.Network
            };

            m_Messgae.To.Add(new MailAddress(recieve));
            m_Smtpclient.SendCompleted += (s, e) =>
            {
                callback?.Invoke(e);
                Dispose();
            };
            m_Smtpclient.SendMailAsync(m_Messgae);
        }


        /// <summary>
        /// 释放
        /// </summary>
        static public void Dispose()
        {
            if (m_Messgae != null)
                m_Messgae.Dispose();
            if (m_Smtpclient != null)
                m_Smtpclient.Dispose();

            m_Messgae = null;
            m_Smtpclient = null;
        }
    }
}

