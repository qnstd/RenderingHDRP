using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// ������ز���
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class AssemblyUtils
    {
        /// <summary>
        /// ��ȡ�������͵���������
        /// </summary>
        /// <param name="aAppDomain"></param>
        /// <param name="aType"></param>
        /// <returns></returns>
        static public System.Type[] GetAllDerivedTypes(System.AppDomain aAppDomain, System.Type aType)
        {
            var result = new List<System.Type>();
            var assemblies = aAppDomain.GetAssemblies();
            foreach (var assembly in assemblies)
            {
                var types = assembly.GetTypes();
                foreach (var type in types)
                {
                    if (type.IsSubclassOf(aType))
                        result.Add(type);
                }
            }
            return result.ToArray();
        }


    }
}