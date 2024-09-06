using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 镜面雨滴着色检视板
    /// <para>作者：强辰</para>
    /// </summary>
    public class RainDropShaderGUI : ShaderGraphGUI
    {
        bool m_DensityFlag = true;

        protected override void ExtensionProps()
        {
            m_Editor.IntSliderShaderProperty(FindProp("_Blur"), new GUIContent("MipMap Level"));
            DrawShaderProperty("_Tile", "Tile");
            DrawShaderProperty("_Aspect", "Aspect");
            DrawShaderProperty("_TrailDensity", "Trail Density");
            DrawShaderProperty("_Speed", "Downspeed");
            DrawShaderProperty("_RainDropXMove", "X-Move Offset Range");
            DrawShaderProperty("_TwistForce", "Force");
            DrawShaderProperty("_Alp", "Alpha");

            Gui.Space(5);
            m_DensityFlag = EditorGUILayout.Foldout(m_DensityFlag, "Layers");
            if (m_DensityFlag)
            {
                Gui.Space(7);
                Gui.IndentLevelAdd();
                Gui.Help("x：scale  \ny：offset  \nzw: unused", MessageType.None);
                Gui.Space(3);
                DrawShaderProperty("_Layer1", "L1");
                DrawShaderProperty("_Layer2", "L2");
                Gui.IndentLevelSub();
                Gui.Space(5);
            }
        }
    }

}