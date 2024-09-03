using System;
using System.ComponentModel;
using System.Net;
using System.Net.Mail;
using System.Text;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// �ʼ�����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class MailUtils
    {
        #region ����
        const string host = "smtp.qq.com"; // SMTP�ʼ������ַ
        const int port = 587;  // ����˿�
        const string sender = "3186979926@qq.com"; // �����ʼ����õ�����
        const string password = "ermnnjjcotnmdhbh"; //���͵����루��������Ȩ���룩
        const string recieve = "qchen227@outlook.com"; // �����ʼ�������
        #endregion

        const string info = "Email come from: {0}\n\n" + "Description: \n{1}";


        static MailMessage m_Messgae;
        static SmtpClient m_Smtpclient;


        /// <summary>
        /// �����ʼ�
        /// </summary>
        /// <param name="email">�ʼ�</param>
        /// <param name="title">����</param>
        /// <param name="content">����</param>
        /// <param name="callback">�ص�</param>
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
        /// �ͷ�
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