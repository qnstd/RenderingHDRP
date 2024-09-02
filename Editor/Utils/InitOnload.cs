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
            GraphiSettings.LoadAll(); // 加载 Graphi 着色库所有的配置项
            GetGraphiLibIcons(); // Graphi 着色库图标集

            // Unity IDE退出时的监听
            EditorApplication.quitting -= Exiting;
            EditorApplication.quitting += Exiting;

            // Unity IDE刷新
            EditorApplication.update -= Update;
            EditorApplication.update += Update;

            // Hierarchy 变化
            EditorApplication.hierarchyChanged -= OnHierarchyChange;
            EditorApplication.hierarchyChanged += OnHierarchyChange;
            EditorApplication.hierarchyWindowItemOnGUI -= OnHierarchyWindowItemOnGUI;
            EditorApplication.hierarchyWindowItemOnGUI += OnHierarchyWindowItemOnGUI;
        }


        #region 功能
        static Object m_HierarchySelectObj_Twist = null; // 记录在当前场景中选中的热扭曲驱动器
        static List<string> m_GraphiIconNames = new List<string>(); // 记录 Graphi 着色库包含的图表集


        /// <summary>
        /// 获取 Graphi 着色库包含的图标集
        /// </summary>
        static void GetGraphiLibIcons()
        {
            m_GraphiIconNames.Clear();
            Tools.GetFiles
            (
                "Packages/com.graphi.renderhdrp/Editor/Images", 
                ref m_GraphiIconNames, 
                new string[] { ".png" }
            );
        }


        /// <summary>
        /// Hierarchy 列表视图发生改变
        /// </summary>
        static void OnHierarchyChange()
        {
            if (EditorApplication.isPlaying) { return; }

            #region 不允许修改热扭曲驱动器的名称
            if (m_HierarchySelectObj_Twist != null)
            {
                string name = GraphiMachine.C_BuildinLayer[0];
                if (m_HierarchySelectObj_Twist.name != name)
                {
                    m_HierarchySelectObj_Twist.name = name;
                    Lg.Err("Changing the name of the twist drive is not allowed！");
                }
            }
            #endregion
        }



        /// <summary>
        /// 选中 Hierarchy 视图列表中的对象
        /// </summary>
        /// <param name="instanceID"></param>
        /// <param name="selectRect"></param>
        static void OnHierarchyWindowItemOnGUI(int instanceID, Rect selectRect)
        {
            if (EditorApplication.isPlaying) { return; }

            #region 记录创建的热扭曲驱动器
            if (Event.current != null && selectRect.Contains(Event.current.mousePosition))
            {
                if (Event.current.button == 0 && Event.current.type <= EventType.MouseDown)
                {//鼠标左键按下
                    Object obj = EditorUtility.InstanceIDToObject(instanceID);
                    if (obj != null && obj.name == GraphiMachine.C_BuildinLayer[0])
                    {
                        m_HierarchySelectObj_Twist = obj;
                    }
                }
            }
            #endregion


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
            // 当 Unity 第一次被打开
            int isStart = CacheData.GetFirstRunUnity;
            if (isStart <= 0)
            {
                isStart++;
                CacheData.SetFirstRunUnity(isStart);
                OnOpenUnity();
            }

            // 自定义 Toolbar
            ToolbarOperate.Draw();
        }



        /// <summary>
        /// 在第一次打开Unity时触发
        /// </summary>
        static void OnOpenUnity()
        {
            // 弹出 Graphi "关于"面板
            if (GraphiSettings.GlobalSettings != null && GraphiSettings.GlobalSettings.m_PushDialogAbout)
            {
                About.Run();
            }
        }


        /// <summary>
        /// Unity IDE 关闭时需要处理的操作
        /// </summary>
        /// <returns></returns>
        static void Exiting()
        {
            CacheData.SetFirstRunUnity(0);
        }
        #endregion
    }
}