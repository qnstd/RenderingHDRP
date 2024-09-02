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
    /// ��̬�ű���ز��������롢ִ�еȣ�
    /// <para>���ߣ�ǿ��</para>
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
            m_CompilerParams.GenerateInMemory = true; // �ڴ�ִ��
        }



        // ������
        const string C_ClassName = "GraphiDynamicCode";

        /// <summary>
        /// ����Զ�����ű�
        /// </summary>
        /// <param name="customUsing">using ����</param>
        /// <param name="methodCode">������</param>
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
        /// �Զ��庯������
        /// <para>ʹ��ͳһ�������Զ�����������</para>
        /// </summary>
        /// <param name="methodCode">����Ĳ�������������������</param>
        /// <param name="usings">using����</param>
        /// <returns>null������ʧ�ܣ����򷵻�CompileResults����</returns>
        public CompilerResults Compile(string methodCode, string usings = "")
        {
            if (string.IsNullOrEmpty(methodCode)) { return null; }
            return compile(CombineCode(usings, methodCode));
        }


        /// <summary>
        /// �Զ��������
        /// </summary>
        /// <param name="clscode">��������ű�</param>
        /// <returns>null������ʧ�ܣ����򷵻�CompileResults����</returns>
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
                    sb.AppendLine("code��" + e.ErrorNumber + ", tip��" + e.ErrorText);
                }
                Lg.Err("��dynamic script compile error�� " + sb.ToString());
                return null;
            }
            return cr;
        }


        /// <summary>
        /// �����Զ��庯������ȡ�ض����Զ�����ʵ������
        /// </summary>
        /// <param name="methodCode">����Ĳ�������������������</param>
        /// <param name="usings">using����</param>
        /// <returns>null����ʵ������</returns>
        public object CompileAndGetInstance(string methodCode, string usings = "")
        {
            CompilerResults cr = Compile(methodCode, usings);
            if (cr == null) { return null; }
            return GetInstanceObject(cr, C_ClassName) ;
        }


        /// <summary>
        /// �ӱ���ĳ����д����������ʵ������
        /// </summary>
        /// <param name="cr">����ĳ���</param>
        /// <param name="clsname">������</param>
        /// <returns>ʧ�ܣ�null���ɹ�����ʵ������</returns>
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
        /// ��ȡ��ʵ�������е�ĳһ����
        /// </summary>
        /// <param name="inst">ʵ������</param>
        /// <param name="methodName">������</param>
        /// <returns>����</returns>
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
        /// ִ���Զ��庯��
        /// </summary>
        /// <param name="mi">�Զ��庯��</param>
        /// <param name="inst">�Զ��庯�����ڵ���ʵ������</param>
        /// <param name="p">�Զ��庯������</param>
        /// <returns>�Զ��庯������ֵ</returns>
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