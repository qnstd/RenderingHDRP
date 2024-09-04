using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 脚本在加载或被重新编译时触发
    /// <para>作者：强辰</para>
    /// </summary>
    [InitializeOnLoad]
    public class InitOnload
    {
        /// <summary>
        /// 静态初始化
        /// </summary>
        static InitOnload()
        {
            GetGraphiLibIcons(); // Graphi 着色库图标集

            // Unity IDE刷新
            EditorApplication.update -= Update;
            EditorApplication.update += Update;

            // Hierarchy 
            EditorApplication.hierarchyWindowItemOnGUI -= OnHierarchyWindowItemOnGUI;
            EditorApplication.hierarchyWindowItemOnGUI += OnHierarchyWindowItemOnGUI;
        }


        #region 功能
        static List<string> m_GraphiIconNames = new List<string>(); // 记录 Graphi 着色库包含的图表集


        /// <summary>
        /// 获取 Graphi 着色库包含的图标集
        /// </summary>
        static void GetGraphiLibIcons()
        {
            m_GraphiIconNames.Clear();
            ProjectUtils.GetFiles
            (
                "Packages/com.cngraphi.renderhdrp/Editor/Images",
                ref m_GraphiIconNames,
                new string[] { ".png" }
            );
        }



        /// <summary>
        /// 选中 Hierarchy 视图列表中的对象
        /// </summary>
        /// <param name="instanceID"></param>
        /// <param name="selectRect"></param>
        static void OnHierarchyWindowItemOnGUI(int instanceID, Rect selectRect)
        {
            if (EditorApplication.isPlaying) { return; }

            #region 在 Hierarchy 列表内，显示 Graphi 着色库包含的对象图标
            GUIContent objectContent = EditorGUIUtility.ObjectContent(EditorUtility.InstanceIDToObject(instanceID), null);
            if (objectContent != null && objectContent.image != null)
            {
                int indx = m_GraphiIconNames.FindIndex(0, m_GraphiIconNames.Count, (s) =>
                {
                    return s.IndexOf(objectContent.image.name) != -1;
                });
                if (indx == -1) { return; }
                GUI.DrawTexture(new Rect(selectRect.xMax - 16, selectRect.yMin, 16, 16), objectContent.image);
            }
            #endregion
        }



        /// <summary>
        /// Unity IDE 刷新
        /// </summary> 
        static void Update()
        {
            ToolbarOperate.Draw();
        }

        #endregion
    }
}