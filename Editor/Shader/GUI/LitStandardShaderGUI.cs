using UnityEditor;
using static UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInBaseShaderGUI;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 标准光照 ShaderGUI
    /// <para>作者：强辰</para>
    /// </summary>
    public class LitStandardShaderGUI : NodeShaderGUI
    {
        public override void Draw(MaterialEditor editor, MaterialProperty[] props)
        {
            // 基础数据
            Gui.Space(10);
            DrawTex("反照率贴图", ShaderPropIDs.ID_AlbedoTex, ShaderPropIDs.ID_AlbedoColor, editor, props);
            Gui.Space(2);
            DrawTex("法线贴图", ShaderPropIDs.ID_NormalTex, editor, props);
            Gui.Space(2);
            Gui.IndentLevelAdd(2);
            if (!IsNullTex(ShaderPropIDs.ID_NormalTex, props))
                DrawRange("法线强度", ShaderPropIDs.ID_NormalStrength, editor, props);
            Gui.IndentLevelSub(2);
            Gui.Space(2);
            DrawTex("PBR数据贴图", ShaderPropIDs.ID_MaskTex, editor, props);
            Gui.IndentLevelAdd(2);
            if (!IsNullTex(ShaderPropIDs.ID_MaskTex, props))
            {
                FindProperty(ShaderPropIDs.ID_UseRemapping, props).floatValue = 1;
                DrawMaxMinSlider(ShaderPropIDs.ID_MetallicRemapping, 0, 1, "金属度", editor, props);
                DrawMaxMinSlider(ShaderPropIDs.ID_SmoothRemapping, 0, 1, "平滑度", editor, props);
                DrawMaxMinSlider(ShaderPropIDs.ID_AORemapping, 0, 1, "AO", editor, props);
            }
            else
            {
                FindProperty(ShaderPropIDs.ID_UseRemapping, props).floatValue = 0;
                DrawRange("金属度", ShaderPropIDs.ID_Metallic, editor, props);
                DrawRange("平滑度", ShaderPropIDs.ID_Smooth, editor, props);
            }
            Gui.IndentLevelSub(2);
            Gui.Space(2);
            DrawTex("清漆贴图", ShaderPropIDs.ID_CoatTex, ShaderPropIDs.ID_Coat, editor, props);
            if ((SurfaceType)FindProperty("_SurfaceType", props).floatValue == SurfaceType.Transparent)
            {
                Gui.Space(2);
                DrawRange("透明度", ShaderPropIDs.ID_Alpha, editor, props);
            }
            Gui.Space(2);
            DrawDefault(ShaderPropIDs.ID_TillingAndOffset, "贴图的缩放偏移", editor, props);


            // 细节
            DrawTex("细节贴图", ShaderPropIDs.ID_DetailTex, editor, props);
            if (!IsNullTex(ShaderPropIDs.ID_DetailTex, props))
            {
                Gui.IndentLevelAdd(2);
                DrawDefault(ShaderPropIDs.ID_LockAlbedoTillingAndOffset, "锁定反照率贴图的缩放及偏移", editor, props);
                DrawDefault(ShaderPropIDs.ID_DetailTillingAndOffset, "缩放偏移", editor, props);
                DrawRange("反照率强度", ShaderPropIDs.ID_DetailAlbedoScal, editor, props);
                DrawRange("法线强度", ShaderPropIDs.ID_DetailNormalScal, editor, props);
                DrawRange("平滑度强度", ShaderPropIDs.ID_DetailSmoothnessScal, editor, props);
                Gui.IndentLevelSub(2);
            }


            // 自发光
            Gui.Space(10);
            DrawDefault(ShaderPropIDs.ID_EmissionTex, "自发光贴图", editor, props);
            Gui.IndentLevelAdd();
            DrawDefault(ShaderPropIDs.ID_EmissionClr, "混合颜色", editor, props);
            DrawDefault(ShaderPropIDs.ID_MultiplyAlbedo, "是否将反照率参与自发光混合", editor, props);
            DrawDefault(ShaderPropIDs.ID_ExposureWeight, "曝光权重", editor, props);
            Gui.IndentLevelSub();

        }
    }
}

