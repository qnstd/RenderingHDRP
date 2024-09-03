using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// Unity Project 操作
    /// <para>作者：强辰</para>
    /// </summary>
    public class ProjectUtils
    {
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
    }

}