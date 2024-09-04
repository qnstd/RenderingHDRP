using System.Collections.Generic;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 程序集相关操作
    /// <para>作者：强辰</para>
    /// </summary>
    public class AssemblyUtils
    {
        /// <summary>
        /// 获取参数类型的所有子类
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