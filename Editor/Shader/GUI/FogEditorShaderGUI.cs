using UnityEditor;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 场景雾效着色器面板
    /// <para>作者：强辰</para>
    /// </summary>
    public class FogEditorShaderGUI : GeneralEditorShaderGUI
    {
        protected override void FurtherSelect(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.FurtherSelect(materialEditor, properties);
        }
    }

}

