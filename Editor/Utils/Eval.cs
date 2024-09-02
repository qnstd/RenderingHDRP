using Microsoft.CSharp;
using System;
using System.CodeDom.Compiler;
using System.Linq;
using System.Reflection;
using System.Text;
using UnityEditor;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 动态脚本相关操作（编译、执行等）
    /// <para>作者：强辰</para>
    /// </summary>
    public class Eval
    {
        static private Eval _Instance = null;
        static public Eval Instance
        {
            get
            {
                if (_Instance == null)
                {
                    _Instance = new Eval();
                }
                return _Instance;
            }
        }


        CSharpCodeProvider m_Provider;
        CompilerParameters m_CompilerParams;


        public Eval()
        {
            if (_Instance != null)
            {
                throw new Exception("Singleton class cannot be repeated");
            }
            _Instance = this;

            m_Provider = new CSharpCodeProvider();
            m_CompilerParams = new CompilerParameters();

            var assemlys = AppDomain.CurrentDomain 
                            .GetAssemblies()
                            .Where(a => !a.IsDynamic)
                            .Select(a => a.Location);
            m_CompilerParams.ReferencedAssemblies.AddRange(assemlys.ToArray());

            m_CompilerParams.GenerateExecutable = false;
            //m_CompilerParams.GenerateInMemory = false;
            //string assemblyName = Time.realtimeSinceStartup + ".dll";
            //m_CompilerParams.OutputAssembly = Path.Combine(FileUtil.GetUniqueTempPathInProject(), "GeneralCodeTemp", assemblyName);
            m_CompilerParams.GenerateInMemory = true; // 内存执行
        }



        // 类名称
        const string C_ClassName = "GraphiDynamicCode";

        /// <summary>
        /// 组合自定义类脚本
        /// </summary>
        /// <param name="customUsing">using 引用</param>
        /// <param name="methodCode">函数体</param>
        /// <returns></returns>
        private string CombineCode(string customUsing, string methodCode)
        {
            StringBuilder sb = new StringBuilder();
            sb
            // using
                .AppendLine((string.IsNullOrEmpty(customUsing) ? "" : customUsing))
            // class
                .AppendLine("public class " + C_ClassName + "{")
            // method
                .AppendLine(methodCode)
            // end
                .AppendLine("}");

            return sb.ToString();
        }



        /// <summary>
        /// 自定义函数编译
        /// <para>使用统一的内置自定义类来编译</para>
        /// </summary>
        /// <param name="methodCode">具体的操作函数及函数体内容</param>
        /// <param name="usings">using引用</param>
        /// <returns>null：编译失败；否则返回CompileResults对象</returns>
        public CompilerResults Compile(string methodCode, string usings = "")
        {
            if (string.IsNullOrEmpty(methodCode)) { return null; }
            return compile(CombineCode(usings, methodCode));
        }


        /// <summary>
        /// 自定义类编译
        /// </summary>
        /// <param name="clscode">完整的类脚本</param>
        /// <returns>null：编译失败；否则返回CompileResults对象</returns>
        public CompilerResults Compile(string clscode)
        {
            if (string.IsNullOrEmpty(clscode)) { return null; }
            return compile(clscode);
        }


        private CompilerResults compile(string c)
        {
            CompilerResults cr = m_Provider.CompileAssemblyFromSource(m_CompilerParams, c);
            if (cr.Errors.HasErrors)
            {
                StringBuilder sb = new StringBuilder();
                foreach (CompilerError e in cr.Errors)
                {
                    sb.AppendLine("code：" + e.ErrorNumber + ", tip：" + e.ErrorText);
                }
                Lg.Err("【dynamic script compile error】 " + sb.ToString());
                return null;
            }
            return cr;
        }


        /// <summary>
        /// 编译自定义函数并获取特定的自定义类实例对象
        /// </summary>
        /// <param name="methodCode">具体的操作函数及函数体内容</param>
        /// <param name="usings">using引用</param>
        /// <returns>null或者实例对象</returns>
        public object CompileAndGetInstance(string methodCode, string usings = "")
        {
            CompilerResults cr = Compile(methodCode, usings);
            if (cr == null) { return null; }
            return GetInstanceObject(cr, C_ClassName) ;
        }


        /// <summary>
        /// 从编译的程序集中创建参数类的实例对象
        /// </summary>
        /// <param name="cr">编译的程序集</param>
        /// <param name="clsname">类名称</param>
        /// <returns>失败：null，成功：类实例对象</returns>
        public object GetInstanceObject(CompilerResults cr, string clsname)
        {
            if (cr == null || string.IsNullOrEmpty(clsname)) { return null; }
            object inst = null;
            try
            {
                inst = cr.CompiledAssembly.CreateInstance(clsname);
            }
            catch (Exception e) { Lg.Err(e.Message); }
            return inst;
        }



        /// <summary>
        /// 获取类实例对象中的某一函数
        /// </summary>
        /// <param name="inst">实例对象</param>
        /// <param name="methodName">函数名</param>
        /// <returns>函数</returns>
        public MethodInfo GetMethod(object inst, string methodName)
        {
            MethodInfo mi = null;
            try
            {
                mi = inst.GetType().GetMethod(methodName);
            }
            catch(Exception e) { Lg.Err(e.Message); }
            return mi;
        }



        /// <summary>
        /// 执行自定义函数
        /// </summary>
        /// <param name="mi">自定义函数</param>
        /// <param name="inst">自定义函数所在的类实例对象</param>
        /// <param name="p">自定义函数参数</param>
        /// <returns>自定义函数返回值</returns>
        public object Excute(MethodInfo mi, object inst, params object[] p)
        {
            object result = null;
            try
            {
                result = mi.Invoke(inst, p);
            }
            catch(Exception e) { Lg.Err(e.Message); }
            return result;
        }

    }
}