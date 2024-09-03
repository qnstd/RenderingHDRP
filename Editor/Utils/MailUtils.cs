using System;
using System.ComponentModel;
using System.Net;
using System.Net.Mail;
using System.Text;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 邮件工具
    /// <para>作者：强辰</para>
    /// </summary>
    public class MailUtils
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