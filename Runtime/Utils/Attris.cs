using System;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 变量的自定义属性
    /// <para>作者：强辰</para>
    /// </summary>
    [AttributeUsage(AttributeTargets.Field)]
    public class FieldAttr : PropertyAttribute
    {
        string m_sLabel;
        string m_sDetail;

        int m_iIndentLevel; // 编辑器模式使用


        public FieldAttr
            (
                string label, 
                string detail = "",
                int indentLevel = 0 
            )
        {
            m_sLabel = string.IsNullOrEmpty(label) ? "" : label;
            m_sDetail = string.IsNullOrEmpty(detail) ? "" : detail;
            m_iIndentLevel = indentLevel;
        }


        /// <summary>
        /// 变量说明
        /// </summary>
        public string Label { get { return m_sLabel; } }
        /// <summary>
        /// 变量的详细描述信息
        /// </summary>
        public string Detail { get { return m_sDetail; } }
        /// <summary>
        /// 在Inspector中的层级
        /// </summary>
        public int IndentLevel { get { return m_iIndentLevel; } }
    }

}