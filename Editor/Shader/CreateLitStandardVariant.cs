using System.IO;
using UnityEditor;
using UnityEngine;
using static UnityEngine.Rendering.HighDefinition.DrawRenderersCustomPass;

namespace com.graphi.renderhdrp.editor
{

    /// <summary>
    /// 创建标准光照着色器的变种文件
    /// <para>作者：强辰</para>
    /// </summary>
    public class CreateLitStandardVariant : EditorWindow
    {
        static Vector2 C_SIZE = new Vector2(330, 115);


        [MenuItem("Assets/Create/Shader Graph/HDRP/Lit Standard Variant")]
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
                richText = true,
                fontSize = 10
            };
            GUIStyle sty2 = EditorStyles.helpBox;

            Gui.Space(15);
            int _w = 80;
            Gui.Hor();
            Gui.Label("Filename： <color=#fa5b93ff>*</color>", sty, 125);
            m_name = EditorGUILayout.TextField(m_name, sty2);
            Gui.EndHor();

            Gui.Space(5);
            Gui.Hor();
            Gui.Label("Material：", sty, _w);
            m_bCreateMat = EditorGUILayout.Toggle(m_bCreateMat);
            Gui.EndHor();

            float w = 100, h = 22;
            Gui.Area((C_SIZE.x - w) * 0.5f, C_SIZE.y - h - 10, w, h);
            Gui.Btn("Build", () => { Create(); }, null, Gui.H(h));
            Gui.EndArea();
        }


        private void Create()
        {
            if (!ProjectUtils.SelectDirectory(out m_path)) { return; }
            if (string.IsNullOrEmpty(m_name))
            {
                Gui.Dialog("Params Error！");
                return;
            }
            string tarFileName = m_name + ".shadergraph";
            string tarp = Path.Combine(m_path, tarFileName).Replace("\\", "/");
            if (File.Exists(tarp))
            {
                int rs = Gui.Confirm("There is a Shader file with the same name in the current path, and there may be a shader path conflict, are you sure to create it?", "Tip", "build", "cancel");
                if (rs != 0) { return; }
            }

            string srcp = ProjectUtils.FindexactFile("Runtime/Shader/Lit", $"{C_LitStandardVariantShaderName}.shadergraph");
            File.Copy(srcp, tarp, true);

            Shader sha = AssetDatabase.LoadAssetAtPath<Shader>(srcp);
            string shapath = sha.name.Substring(0, sha.name.LastIndexOf("/") + 1) + m_name;
            //Lg.Trace(shapath);

            AssetDatabase.Refresh();

            // 创建材质
            if (m_bCreateMat)
            {
                if (!ProjectUtils.SelectDirectory(out string p)) { return; }
                p = Path.Combine(p, m_name + ".mat").Replace("\\", "/");
                AssetDatabase.CreateAsset(new Material(ShaderFind.GetTradition(shapath)), p);
                AssetDatabase.Refresh();
            }

            Close();
            Gui.Dialog
                (
                    "Success! \n\n" +
                    "Shader Path：" + shapath + "\n\n" +
                    "File path：" + tarp
                );
        }

    }
}