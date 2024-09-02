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
    /// 输出/打印
    /// <para>作者：强辰</para>
    /// </summary>
    public class Lg
    {
        //输出类型
        private enum E_LgType
        {
            /// <summary>
            /// 常规输出
            /// </summary>
            TRACE,
            /// <summary>
            /// 错误输出
            /// </summary>
            ERR,
            /// <summary>
            /// 警告
            /// </summary>
            WARN
        }


        #region 变量/常量
        //输出信息缓存组
        static private ConcurrentQueue<string> m_lginfos = new ConcurrentQueue<string>();
        //堆栈信息格式化字符串
        private const string C_StackInfo_Str = "[Stack: FileName( {0} ), Method( {1} ), Line( {2} )]";

        static private Dictionary<E_LgType, List<string>> C_Prefixs = new Dictionary<E_LgType, List<string>>()
        {
            { E_LgType.TRACE, new List<string>(){ "#8cfc80ff" } },
            { E_LgType.WARN, new List<string>(){ "#f9ec80ff" } },
            { E_LgType.ERR, new List<string>(){ "#fa4f4fff" } },
        };
        #endregion



        /// <summary>
        /// 打印输出
        /// </summary>
        /// <param name="typ">输出类型</param>
        /// <param name="args">输出参数</param>
        static private void Print(E_LgType typ, object[] args)
        {
            if(args == null || args.Length == 0) { return; }

            StringBuilder sb = new StringBuilder();
           
            //标题
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

            //内容
            int lv = 0;
            foreach(object o in args)
            {
                Push(o, sb, ref lv, "", "-> ");
            }

            //显示
            string message = sb.ToString();
            Debug.Log(message);
            CacheLg(message);

            //清理
            sb.Clear();
        }


        /// <summary>
        /// 堆栈信息
        /// </summary>
        /// <returns></returns>
        static private string Stack()
        {
            StackTrace st = new StackTrace(true);
            StackFrame[] frames = st.GetFrames();
            //从堆栈列表中跳过 Stack/Print/（Trace，Err，Warn）函数栈。选取输出信息语句所在的文件及函数等信息。
            if(frames.Length < 4) { return ""; }

            StackFrame sf = frames[3];
            string[] strs = sf.GetFileName().Replace("\\", "/").Split("/");
            string filename = strs[strs.Length - 1];

            return string.Format(C_StackInfo_Str, filename, sf.GetMethod().Name, sf.GetFileLineNumber());
        }


        /// <summary>
        /// 递归 Dictionary
        /// </summary>
        /// <param name="o">Dictonry</param>
        /// <param name="sb">字符缓存器</param>
        /// <param name="lv">节点等级</param>
        /// <param name="space">节点等级对应的显示距离偏移</param>
        static private void RecursionDic(object o, StringBuilder sb, ref int lv, string space)
        {
            IDictionary dic = (IDictionary)o;
            foreach(object k in dic.Keys)
            {
                Push(dic[k], sb, ref lv, space, "key = " + k + " / value = ");
            }
        }


        /// <summary>
        /// 递归 List
        /// </summary>
        /// <param name="o">list列表</param>
        /// <param name="sb">字符缓存器</param>
        /// <param name="lv">节点等级</param>
        /// <param name="space">节点等级对应的显示距离偏移</param>
        static private void RecursionList(object o, StringBuilder sb, ref int lv, string space)
        {
            IList lst = (IList)o;
            for (int i = 0; i < lst.Count; i++)
            {
                Push(lst[i], sb, ref lv, space, "[" + i + "] = ");
            }
        }


        /// <summary>
        /// 压入输出信息
        /// </summary>
        /// <param name="obj">值对象</param>
        /// <param name="sb">字符缓冲器</param>
        /// <param name="lv">节点等级</param>
        /// <param name="space">节点等级对应的显示距离偏移</param>
        /// <param name="prefix">输出信息的前缀</param>
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
            {//列表类型
                lv++;
                sb.Append(space + prefix + "*List").AppendLine();
                RecursionList(obj, sb, ref lv, LevelSpace(lv));
                lv--;
            }
            else if (_typname.IndexOf("dictionary") != -1)
            {//字典类型
                lv++;
                sb.Append(space + prefix + "*Dictionary").AppendLine();
                RecursionDic(obj, sb, ref lv, LevelSpace(lv));
                lv--;
            }
            else if(_typname == "string")
            {//字符串类型
                sb.Append(space + prefix + "\"" + obj.ToString() + "\"").AppendLine();
            }
            else
            {//其他类型
                sb.Append(space + prefix + obj.ToString()).AppendLine();
            }
        }

        
        /// <summary>
        /// 通过节点等级计算显示距离的偏移
        /// </summary>
        /// <param name="lv">节点等级</param>
        /// <returns></returns>
        static private string LevelSpace(int lv)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = lv - 1; i >= 0; i--)
                sb.Append("     ");
            return sb.ToString();
        }


        #region 对外接口

        /// <summary>
        /// 常规输出
        /// </summary>
        /// <param name="args"></param>
        static public void Trace(params object[] args)
        {
            Print(E_LgType.TRACE, args);
        }
        /// <summary>
        /// 错误输出
        /// </summary>
        /// <param name="args"></param>
        static public void Err(params object[] args)
        {
            Print(E_LgType.ERR, args);
        }
        /// <summary>
        /// 警告输出
        /// </summary>
        /// <param name="args"></param>
        static public void Warn(params object[] args)
        {
            Print(E_LgType.WARN, args);
        }


        #region 日志
        /// <summary>
        /// 缓存输出
        /// </summary>
        /// <param name="msg">输出信息</param>
        static private void CacheLg(string msg)
        {
            if (!Cache) { return; }
            if (string.IsNullOrEmpty(msg)) { return; }

            if (m_lginfos.Count == CacheNumber)
            {//当前缓存数量 == 最大缓存，则将队列中的第一个移除
                m_lginfos.TryDequeue(out string _);
            }
            m_lginfos.Enqueue(msg);
        }
        /// <summary>
        /// 是否缓存输出信息（默认：关闭）
        /// </summary>
        static public bool Cache { set; get; } = false;
        /// <summary>
        /// 输出缓存最大数量（默认：100条）
        /// </summary>
        static public int CacheNumber { set; get; } = 100;
        /// <summary>
        /// 清理缓存
        /// </summary>
        static public void ClearCache()
        {
            if (m_lginfos != null)
                m_lginfos.Clear();
        }
        /// <summary>
        /// 获取输出缓存信息
        /// </summary>
        /// <returns></returns>
        static public string GetCache() 
        {
            if(m_lginfos == null || m_lginfos.IsEmpty) { return ""; }
            return string.Join("\n", m_lginfos); 
        }
        /// <summary>
        /// 保存当前缓存的输出信息<br></br>
        /// 1. 本地写入需确保参数目录有写入权限；<br></br>
        /// 2. 如果目录内存在参数文件名的文件，则直接写入替换；
        /// </summary>
        /// <param name="path">保存目录</param>
        /// <param name="name">文件名（需要携带文件名后缀）</param>
        /// <param name="async">是否异步写入（默认：同步）</param>
        static public void SaveCache(string path, string name, bool async=false)
        {
            if (!Cache) { return; }

            if (string.IsNullOrEmpty(path) || string.IsNullOrEmpty(name)) { return; }
            if (!Directory.Exists(path)) { return; } //目录不存在

            string msg = GetCache();
            if (string.IsNullOrEmpty(msg)) { return; } //信息为空

            string p = Path.Combine(path, name).Replace("\\", "/");
            if (async)
            {//异步写入
                WriteCacheAsync(p, msg);
            }
            else
            {//同步写入
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