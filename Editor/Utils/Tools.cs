using System.IO;
namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// 工具包
    /// <para>作者：强辰</para>
    /// </summary>
    public class Tools
    {
#if UNITY_EDITOR
        /// <summary>
        /// 在 Graphi 渲染库目录获取文件
        /// </summary>
        /// <param name="relpath">相对着色库根目录的子目录集</param>
        /// <param name="filename">文件名</param>
        /// <returns></returns>
        static public string FindexactFile(string relpath, string filename)
        {
            string p = Path.Combine
                        (
                            "Packages/com.cngraphi.renderhdrp",
                            relpath,
                            filename
                        );
            p = p.Replace("\\", "/");
            //p = Path.GetFullPath(p); // 获取已打包资源的绝对路径

            if (File.Exists(p))
            {
                return p;
            }
            return null;
        }
#endif

    }
}