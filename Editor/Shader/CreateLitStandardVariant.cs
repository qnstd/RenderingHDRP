using System.IO;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// 创建标准光照着色器的变种文件
    /// <para>作者：强辰</para>
    /// </summary>
    public class CreateLitStandardVariant : EditorWindow
    {
        static Vector2 C_SIZE = new Vector2(330, 115);


        [MenuItem("Assets/Graphi/Shader/Lit Standard Variant (ShaderGraph)")]
        static private void CreateLitStandardVariantSha()
        {
            Gui.ShowWin<CreateLitStandardVariant>("Create LitStandard Variant ShaderGraph", C_SIZE, true);
        }



        const string C_LitStandardVariantShaderName = "LitStandardVariant";
        string m_path = "";
        string m_name = "";
        bool m_bCreateMat = false;



        private void OnDisable()
        {
            m_path = null;
            m_name = null;
        }


        private void OnGUI()
        {
            GUIStyle sty = new GUIStyle("WordWrappedMiniLabel")
            {
                richText=true,
                fontSize = 10
            };
            GUIStyle sty2 = EditorStyles.helpBox;

            Gui.Space(15);
            int _w = 80;
            Gui.Hor();
            Gui.Label("文件名： <color=#fa5b93ff>*</color>", sty, 125);
            m_name = EditorGUILayout.TextField(m_name, sty2);
            Gui.EndHor();

            Gui.Space(10);
            Gui.Hor();
            Gui.Label("是否创建材质：", sty, _w);
            m_bCreateMat = EditorGUILayout.Toggle(m_bCreateMat);
            Gui.EndHor();

            float w = 100, h = 22;
            Gui.Area((C_SIZE.x - w) * 0.5f, C_SIZE.y - h - 10, w, h);
            Gui.Btn("创建", () => { Create(); }, null, Gui.H(h));
            Gui.EndArea();
        }


        private void Create()
        {
            if (!Tools.SelectDirectory(out m_path)) { return; }
            if (string.IsNullOrEmpty(m_name))
            {
                Gui.Dialog("请正确填写必要参数！");
                return;
            }
            string tarFileName = m_name + ".shadergraph";
            string tarp = Path.Combine(m_path, tarFileName).Replace("\\", "/");
            if (File.Exists(tarp))
            {
                int rs = Gui.Confirm("当前路径下存在同名的着色器文件，同时也可能存在 Shader 路径冲突，确定要创建吗？", "提示", "创建", "放弃");
                if (rs != 0) { return; }
            }

            string srcp = renderhdrp.Tools.FindexactFile("Runtime/Shader/Lit", $"{C_LitStandardVariantShaderName}.shadergraph");
            File.Copy(srcp, tarp, true);

            Shader sha = AssetDatabase.LoadAssetAtPath<Shader>(srcp);
            string shapath = sha.name.Substring(0, sha.name.LastIndexOf("/") +1) + m_name;
            //Lg.Trace(shapath);

            AssetDatabase.Refresh();

            // 创建材质
            if (m_bCreateMat)
                CreateShaderMat.Excute(shapath, m_name);

            Close();
            Gui.Dialog
                (
                    "创建完毕! \n\n" +
                    "着色器路径：" + shapath + "\n\n" +
                    "文件路径：" + tarp
                );
        }

    }
}