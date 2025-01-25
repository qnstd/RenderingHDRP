using UnityEngine;
using UnityEngine.Rendering;


namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 长毛发着色器检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class LongWoolShaderGUI : LitStanardVariShaderGUI
    {
        #region 变量
        private bool m_TessFoldout = true; // 曲面细分检视开关
        private bool m_FurFoldout = true; // 毛发
        #endregion


        /// <summary>
        /// 构造
        /// </summary>
        public LongWoolShaderGUI()
        {
            // 修改父类的材质块注册表
            //uiBlocks.Insert(1, new TransparencyUIBlock(MaterialUIBlock.ExpandableBit.Transparency, TransparencyUIBlock.Features.Refraction));
            uiBlocks.RemoveRange(0, uiBlocks.Count);
        }

        protected override void ExtensionProps()
        {
            base.ExtensionProps();

            Gui.Space(20);

            // 绘制源网格像素
            Gui.Check();
            DrawShaderProperty("_DisplayOriginMesh", "Draw Origin Mesh Infos");
            if (Gui.EndCheck())
            {
                Material material = m_Editor.target as Material;
                CoreUtils.SetKeyword(material, "_DRAW_ORIGIN_MESH", material.GetFloat("_DisplayOriginMesh") > 0.0);
            }
            Gui.Space(10);

            // 曲面细分属性绘制
            FoldoutGroup(ref m_TessFoldout, "Tessellation", () =>
            {
                DrawRange("Factor", "_TessFactor");
                DrawMaxMinSlider("_TessMinDist", "_TessMaxDist", 0.1f, 50.0f, "Range");
            });

            // 毛发属性绘制
            FoldoutGroup(ref m_FurFoldout, "Fur", () =>
            {
                DrawTex("ShapeTex", "_FurTex");
                DrawTex("ShapeTex N", "_FurNormalTex", "_FurNormalForce");
                DrawRange("Alpha Threshold", "_CutAlpha");
                DrawRange("Use Surface Normal", "_FaceNormalFactor");
                DrawRange("Face View Threshold", "_FaceViewThreshold");
                DrawIntRange("Near Surface", "_NearSurface");
                DrawRange("Length", "_Length");
                DrawShaderProperty("_Density", "Density");
                DrawRange("Random Direction", "_RandomDirection");
                DrawVector3("_BaseOffset", "Base Offset");
                DrawVector3("_WindAxisWeight", "Wind Axis Weight");
                DrawVector3("_WindAxisSpeed", "Wind Axis Speed");
                DrawShaderProperty("_WindPhase", "Wind Phase");
                DrawShaderProperty("_SwingPow", "Swing Pow");
                DrawRange("AOcc", "_Occ");
            });
        }
    }
}