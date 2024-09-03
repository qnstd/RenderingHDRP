using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// Graphi 编辑模式下的工具类
    /// <para>作者：强辰</para>
    /// </summary>
    public class Tools
    {

        #region Project 检视面板内的操作
        /// <summary>
        /// 获取目录下所有文件
        /// <para>默认忽略其下所有的.meta文件</para>
        /// </summary>
        /// <param name="path"></param>
        /// <param name="lst"></param>
        /// <param name="contains"></param>
        /// <param name="startWithAsset"></param>
        static public void GetFiles(string path, ref List<string> lst, string[] contains, bool startWithAsset = true)
        {
            DirectoryInfo dir = new DirectoryInfo(path);
            FileSystemInfo[] fsi = dir.GetFileSystemInfos();
            foreach (FileSystemInfo f in fsi)
            {
                if (f is DirectoryInfo) { GetFiles(f.FullName, ref lst, contains, startWithAsset); }
                else
                {
                    string p = f.FullName;
                    string ext = Path.GetExtension(p);
                    if (ext == ".meta") { continue; }
                    if (contains != null && Array.IndexOf(contains, ext) == -1) { continue; }
                    p = p.Replace("\\", "/");
                    if (startWithAsset)
                    {
                        int indx = p.IndexOf("Assets");
                        if (indx != -1)
                            p = p.Substring(indx);
                    }
                    lst.Add(p);
                }
            }
        }
        /// <summary>
        /// 获取在 Unity Project 面板内选中的目录
        /// </summary>
        /// <param name="p"></param>
        /// <returns></returns>
        static public bool SelectDirectory(out string p)
        {
            p = "";
            string[] guids = Selection.assetGUIDs;
            if (guids.Length == 0)
            {
                Gui.Dialog("Unselected directory！", "Error");
                return false;
            }
            p = AssetDatabase.GUIDToAssetPath(guids[0]);
            if (!Directory.Exists(p))
            {
                Gui.Dialog("Unselected directory！\n\nTip：\nIn the Project panel activation item, the first selected activation must be the directory.\n", "Error");
                return false;
            }
            return true;
        }
        #endregion


        #region 程序集
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
        /// <summary>
        /// 请求 unity 编译脚本
        /// </summary>
        static public void CompileScripts()
        {
            UnityEditor.Compilation.CompilationPipeline.RequestScriptCompilation();
        }
        #endregion

    }
}