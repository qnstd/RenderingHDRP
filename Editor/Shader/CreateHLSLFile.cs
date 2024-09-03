using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 创建 HLSL 文件
    /// <para>作者：强辰</para>
    /// </summary>
    public class CreateHLSLFile : EditorWindow
    {
        static Vector2 C_SIZE = new Vector2(330, 240);

        [MenuItem("Assets/Graphi/Shader/HLSL")]
        static private void Run()
        {
            Gui.ShowWin<CreateHLSLFile>("Create HLSL File", C_SIZE, true);
        }


        private void OnDisable()
        {
            m_path = null;
            m_name = null;
            m_desc = null;
            m_author = null;
        }


        string m_path = "";
        string m_name = "Graphi-CustomHLSL";
        string m_desc = "自定义 HLSL 文件";
        string m_author = "Graphi";
        const string m_content =
            "#ifndef {0}\n" +
            "#define {1}\n\n" +
            "//TODO: 编写 HLSL 内容\n\n" +
            "//END\n\n" +
            "#endif //{2}（由 Graphi 着色库工具生成）| 作者：{3}";


        private void OnGUI()
        {
            GUIStyle sty = new GUIStyle("WordWrappedMiniLabel");
            sty.richText = true;
            GUIStyle sty2 = EditorStyles.helpBox;

            int _w = 80;
            Gui.Space(12);
            Gui.Hor();
            Gui.Label("Filename: <color=#fa5b93ff>*</color>", sty, _w);
            m_name = EditorGUILayout.TextField(m_name, sty2);
            Gui.EndHor();

            Gui.Space(5);
            Gui.Label("Description: <color=#fa5b93ff>*</color>", sty, _w);
            m_desc = EditorGUILayout.TextArea(m_desc, sty2, Gui.H(100));

            Gui.Space(5);
            Gui.Hor();
            Gui.Label("Author: <color=#fa5b93ff>*</color>", sty, _w);
            m_author = EditorGUILayout.TextField(m_author, sty2);
            Gui.EndHor();

            float w = 100, h = 22;
            Gui.Area((C_SIZE.x - w) * 0.5f, C_SIZE.y - h - 10, w, h);
            Gui.Btn("Build", () => { Create(); }, null, Gui.H(h));
            Gui.EndArea();
        }


        private void Create()
        {
            if (!ProjectUtils.SelectDirectory(out m_path)) { return; }
            if (string.IsNullOrEmpty(m_name) || string.IsNullOrEmpty(m_author) || string.IsNullOrEmpty(m_desc))
            {
                Close();
                Gui.Dialog("Params Error！", "Error");
                return;
            }

            m_author = (string.IsNullOrEmpty(m_author)) ? "" : m_author;
            m_desc = (string.IsNullOrEmpty(m_desc)) ? "" : m_desc;
            string p = Path.Combine(m_path, m_name + ".hlsl").Replace("\\", "/");
            string key = m_name.ToUpper();
            key = key.Replace("-", "_");

            // 内容
            string content = string.Format(m_content, key, key, m_desc, m_author);
            //Lg.Trace(content);
            File.WriteAllText(p, content, Encoding.UTF8);
            AssetDatabase.Refresh();

            Close();
            Gui.Dialog("Create Success！");
        }
    }

}