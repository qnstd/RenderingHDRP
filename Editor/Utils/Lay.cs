using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 层级相关操作
    /// <para>作者：强辰</para>
    /// </summary>
    public class Lay
    {
        /// <summary>
        /// Graphi 渲染库内置层级
        /// </summary>
        static public string[] C_BuildinLayer = new string[]
        {
        // ※※※ 以下注册的顺序不能改变 ※※※

            "TwistDrive", //热扭曲特定渲染层
            "Edges",    // 用于游戏对象在全屏通道描边时所使用的层级
            "OccDisplay", // 用于被遮挡物（非半透明）显示剪影的层级
        };


        /// <summary>
        /// 添加层
        /// </summary>
        /// <param name="layer"></param>
        static public void AddLayer(string layer)
        {
            if (IsHadLayer(layer)) { return; }

            SerializedObject tagManager = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
            SerializedProperty it = tagManager.GetIterator();
            while (it.NextVisible(true))
            {
                if (it.name == "layers")
                {
                    for (int i = 0; i < it.arraySize; i++)
                    {
                        if (i == 3 || i == 6 || i == 7) continue;
                        SerializedProperty sp = it.GetArrayElementAtIndex(i);
                        if (string.IsNullOrEmpty(sp.stringValue))
                        {
                            sp.stringValue = layer;
                            tagManager.ApplyModifiedProperties();
                            Debug.Log("Add layer：" + sp.stringValue);
                            return;
                        }
                    }
                }
            }
        }


        /// <summary>
        /// 是否包含特定层
        /// </summary>
        /// <param name="layer"></param>
        /// <returns>true：存在；false：不存在</returns>
        static public bool IsHadLayer(string layer)
        {
            for (int i = 0; i < UnityEditorInternal.InternalEditorUtility.layers.Length; i++)
            {
                if (UnityEditorInternal.InternalEditorUtility.layers[i].Contains(layer))
                    return true;
            }
            return false;
        }
    }

}