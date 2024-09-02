using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using UnityEditor;

using Debug = UnityEngine.Debug;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ���/��ӡ
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class Lg
    {
        //�������
        private enum E_LgType
        {
            /// <summary>
            /// �������
            /// </summary>
            TRACE,
            /// <summary>
            /// �������
            /// </summary>
            ERR,
            /// <summary>
            /// ����
            /// </summary>
            WARN
        }


        #region ����/����
        //�����Ϣ������
        static private ConcurrentQueue<string> m_lginfos = new ConcurrentQueue<string>();
        //��ջ��Ϣ��ʽ���ַ���
        private const string C_StackInfo_Str = "[Stack: FileName( {0} ), Method( {1} ), Line( {2} )]";

        static private Dictionary<E_LgType, List<string>> C_Prefixs = new Dictionary<E_LgType, List<string>>()
        {
            { E_LgType.TRACE, new List<string>(){ "#8cfc80ff" } },
            { E_LgType.WARN, new List<string>(){ "#f9ec80ff" } },
            { E_LgType.ERR, new List<string>(){ "#fa4f4fff" } },
        };
        #endregion



        /// <summary>
        /// ��ӡ���
        /// </summary>
        /// <param name="typ">�������</param>
        /// <param name="args">�������</param>
        static private void Print(E_LgType typ, object[] args)
        {
            if(args == null || args.Length == 0) { return; }

            StringBuilder sb = new StringBuilder();
           
            //����
            sb
#if UNITY_EDITOR
                .Append("<color=#89d9f6ff><b>[Graphi]</b></color>")
                .Append(" - ")
                .Append("<color=" + C_Prefixs[typ][0] + "><b>[" + typ + "]</b></color>")
#else
                .Append("[Graphi]-["+ typ +"]")
#endif
                .Append(" ")
#if !UNITY_EDITOR
                .Append(DateTime.Now.ToString("[yyyy-MM-dd HH:mm:ss]"))
#endif
#if UNITY_EDITOR
                .Append("<color=#be75c9ff><b>" + Stack() + "</b></color>")
#endif
                .AppendLine();

            //����
            int lv = 0;
            foreach(object o in args)
            {
                Push(o, sb, ref lv, "", "-> ");
            }

            //��ʾ
            string message = sb.ToString();
            Debug.Log(message);
            CacheLg(message);

            //����
            sb.Clear();
        }


        /// <summary>
        /// ��ջ��Ϣ
        /// </summary>
        /// <returns></returns>
        static private string Stack()
        {
            StackTrace st = new StackTrace(true);
            StackFrame[] frames = st.GetFrames();
            //�Ӷ�ջ�б������� Stack/Print/��Trace��Err��Warn������ջ��ѡȡ�����Ϣ������ڵ��ļ�����������Ϣ��
            if(frames.Length < 4) { return ""; }

            StackFrame sf = frames[3];
            string[] strs = sf.GetFileName().Replace("\\", "/").Split("/");
            string filename = strs[strs.Length - 1];

            return string.Format(C_StackInfo_Str, filename, sf.GetMethod().Name, sf.GetFileLineNumber());
        }


        /// <summary>
        /// �ݹ� Dictionary
        /// </summary>
        /// <param name="o">Dictonry</param>
        /// <param name="sb">�ַ�������</param>
        /// <param name="lv">�ڵ�ȼ�</param>
        /// <param name="space">�ڵ�ȼ���Ӧ����ʾ����ƫ��</param>
        static private void RecursionDic(object o, StringBuilder sb, ref int lv, string space)
        {
            IDictionary dic = (IDictionary)o;
            foreach(object k in dic.Keys)
            {
                Push(dic[k], sb, ref lv, space, "key = " + k + " / value = ");
            }
        }


        /// <summary>
        /// �ݹ� List
        /// </summary>
        /// <param name="o">list�б�</param>
        /// <param name="sb">�ַ�������</param>
        /// <param name="lv">�ڵ�ȼ�</param>
        /// <param name="space">�ڵ�ȼ���Ӧ����ʾ����ƫ��</param>
        static private void RecursionList(object o, StringBuilder sb, ref int lv, string space)
        {
            IList lst = (IList)o;
            for (int i = 0; i < lst.Count; i++)
            {
                Push(lst[i], sb, ref lv, space, "[" + i + "] = ");
            }
        }


        /// <summary>
        /// ѹ�������Ϣ
        /// </summary>
        /// <param name="obj">ֵ����</param>
        /// <param name="sb">�ַ�������</param>
        /// <param name="lv">�ڵ�ȼ�</param>
        /// <param name="space">�ڵ�ȼ���Ӧ����ʾ����ƫ��</param>
        /// <param name="prefix">�����Ϣ��ǰ׺</param>
        static private void Push(object obj, StringBuilder sb, ref int lv, string space, string prefix)
        {
            if(obj == null)
            {
                sb.Append(space + prefix + "null").AppendLine();
                return;
            }

            Type _typ = obj.GetType();
            string _typname = _typ.Name.ToLower();
            if (_typname.IndexOf("list") != -1)
            {//�б�����
                lv++;
                sb.Append(space + prefix + "*List").AppendLine();
                RecursionList(obj, sb, ref lv, LevelSpace(lv));
                lv--;
            }
            else if (_typname.IndexOf("dictionary") != -1)
            {//�ֵ�����
                lv++;
                sb.Append(space + prefix + "*Dictionary").AppendLine();
                RecursionDic(obj, sb, ref lv, LevelSpace(lv));
                lv--;
            }
            else if(_typname == "string")
            {//�ַ�������
                sb.Append(space + prefix + "\"" + obj.ToString() + "\"").AppendLine();
            }
            else
            {//��������
                sb.Append(space + prefix + obj.ToString()).AppendLine();
            }
        }

        
        /// <summary>
        /// ͨ���ڵ�ȼ�������ʾ�����ƫ��
        /// </summary>
        /// <param name="lv">�ڵ�ȼ�</param>
        /// <returns></returns>
        static private string LevelSpace(int lv)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = lv - 1; i >= 0; i--)
                sb.Append("     ");
            return sb.ToString();
        }


        #region ����ӿ�

        /// <summary>
        /// �������
        /// </summary>
        /// <param name="args"></param>
        static public void Trace(params object[] args)
        {
            Print(E_LgType.TRACE, args);
        }
        /// <summary>
        /// �������
        /// </summary>
        /// <param name="args"></param>
        static public void Err(params object[] args)
        {
            Print(E_LgType.ERR, args);
        }
        /// <summary>
        /// �������
        /// </summary>
        /// <param name="args"></param>
        static public void Warn(params object[] args)
        {
            Print(E_LgType.WARN, args);
        }


        #region ��־
        /// <summary>
        /// �������
        /// </summary>
        /// <param name="msg">�����Ϣ</param>
        static private void CacheLg(string msg)
        {
            if (!Cache) { return; }
            if (string.IsNullOrEmpty(msg)) { return; }

            if (m_lginfos.Count == CacheNumber)
            {//��ǰ�������� == ��󻺴棬�򽫶����еĵ�һ���Ƴ�
                m_lginfos.TryDequeue(out string _);
            }
            m_lginfos.Enqueue(msg);
        }
        /// <summary>
        /// �Ƿ񻺴������Ϣ��Ĭ�ϣ��رգ�
        /// </summary>
        static public bool Cache { set; get; } = false;
        /// <summary>
        /// ����������������Ĭ�ϣ�100����
        /// </summary>
        static public int CacheNumber { set; get; } = 100;
        /// <summary>
        /// ������
        /// </summary>
        static public void ClearCache()
        {
            if (m_lginfos != null)
                m_lginfos.Clear();
        }
        /// <summary>
        /// ��ȡ���������Ϣ
        /// </summary>
        /// <returns></returns>
        static public string GetCache() 
        {
            if(m_lginfos == null || m_lginfos.IsEmpty) { return ""; }
            return string.Join("\n", m_lginfos); 
        }
        /// <summary>
        /// ���浱ǰ����������Ϣ<br></br>
        /// 1. ����д����ȷ������Ŀ¼��д��Ȩ�ޣ�<br></br>
        /// 2. ���Ŀ¼�ڴ��ڲ����ļ������ļ�����ֱ��д���滻��
        /// </summary>
        /// <param name="path">����Ŀ¼</param>
        /// <param name="name">�ļ�������ҪЯ���ļ�����׺��</param>
        /// <param name="async">�Ƿ��첽д�루Ĭ�ϣ�ͬ����</param>
        static public void SaveCache(string path, string name, bool async=false)
        {
            if (!Cache) { return; }

            if (string.IsNullOrEmpty(path) || string.IsNullOrEmpty(name)) { return; }
            if (!Directory.Exists(path)) { return; } //Ŀ¼������

            string msg = GetCache();
            if (string.IsNullOrEmpty(msg)) { return; } //��ϢΪ��

            string p = Path.Combine(path, name).Replace("\\", "/");
            if (async)
            {//�첽д��
                WriteCacheAsync(p, msg);
            }
            else
            {//ͬ��д��
                File.WriteAllBytes(p, Encoding.UTF8.GetBytes(msg));
#if UNITY_EDITOR
                AssetDatabase.Refresh();
#endif
            }
        }
        static private async void WriteCacheAsync(string path, string msg)
        {
            using (FileStream fs = new FileStream(path, FileMode.Create))
            {
                byte[] bytes = Encoding.UTF8.GetBytes(msg);
                await fs.WriteAsync(bytes, 0, bytes.Length);
                fs.Close();
#if UNITY_EDITOR
                AssetDatabase.Refresh();
#endif
            }
        }
        #endregion


        #endregion
    }
}