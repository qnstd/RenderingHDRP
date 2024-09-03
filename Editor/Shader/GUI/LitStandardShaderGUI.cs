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
            DrawTex("Albedo", ShaderPropIDs.ID_AlbedoTex, ShaderPropIDs.ID_AlbedoColor, editor, props);
            Gui.Space(2);
            DrawTex("Normal", ShaderPropIDs.ID_NormalTex, editor, props);
            Gui.Space(2);
            Gui.IndentLevelAdd(2);
            if (!IsNullTex(ShaderPropIDs.ID_NormalTex, props))
                DrawRange("Force", ShaderPropIDs.ID_NormalStrength, editor, props);
            Gui.IndentLevelSub(2);
            Gui.Space(2);
            DrawTex("Mix", ShaderPropIDs.ID_MaskTex, editor, props);
            Gui.IndentLevelAdd(2);
            if (!IsNullTex(ShaderPropIDs.ID_MaskTex, props))
            {
                FindProperty(ShaderPropIDs.ID_UseRemapping, props).floatValue = 1;
                DrawMaxMinSlider(ShaderPropIDs.ID_MetallicRemapping, 0, 1, "Metallic", editor, props);
                DrawMaxMinSlider(ShaderPropIDs.ID_SmoothRemapping, 0, 1, "Smoothing", editor, props);
                DrawMaxMinSlider(ShaderPropIDs.ID_AORemapping, 0, 1, "AO", editor, props);
            }
            else
            {
                FindProperty(ShaderPropIDs.ID_UseRemapping, props).floatValue = 0;
                DrawRange("Metallic", ShaderPropIDs.ID_Metallic, editor, props);
                DrawRange("Smoothing", ShaderPropIDs.ID_Smooth, editor, props);
            }
            Gui.IndentLevelSub(2);
            Gui.Space(2);
            DrawTex("Clear coat", ShaderPropIDs.ID_CoatTex, ShaderPropIDs.ID_Coat, editor, props);
            if ((SurfaceType)FindProperty("_SurfaceType", props).floatValue == SurfaceType.Transparent)
            {
                Gui.Space(2);
                DrawRange("Alpha", ShaderPropIDs.ID_Alpha, editor, props);
            }
            Gui.Space(2);
            DrawDefault(ShaderPropIDs.ID_TillingAndOffset, "TillingAndOffset", editor, props);


            // 细节
            DrawTex("Detail", ShaderPropIDs.ID_DetailTex, editor, props);
            if (!IsNullTex(ShaderPropIDs.ID_DetailTex, props))
            {
                Gui.IndentLevelAdd(2);
                DrawDefault(ShaderPropIDs.ID_LockAlbedoTillingAndOffset, "Lock Albedo's TillingAndOffset", editor, props);
                DrawDefault(ShaderPropIDs.ID_DetailTillingAndOffset, "TillingAndOffset", editor, props);
                DrawRange("Albedo Force", ShaderPropIDs.ID_DetailAlbedoScal, editor, props);
                DrawRange("Normal Force", ShaderPropIDs.ID_DetailNormalScal, editor, props);
                DrawRange("Smoothing Force", ShaderPropIDs.ID_DetailSmoothnessScal, editor, props);
                Gui.IndentLevelSub(2);
            }


            // 自发光
            Gui.Space(10);
            DrawDefault(ShaderPropIDs.ID_EmissionTex, "Emission", editor, props);
            Gui.IndentLevelAdd();
            DrawDefault(ShaderPropIDs.ID_EmissionClr, "Color", editor, props);
            DrawDefault(ShaderPropIDs.ID_MultiplyAlbedo, "Multiply Albedo", editor, props);
            DrawDefault(ShaderPropIDs.ID_ExposureWeight, "Exposure", editor, props);
            Gui.IndentLevelSub();

        }
    }
}

