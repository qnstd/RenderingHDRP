using System;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// �������Զ�������
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    [AttributeUsage(AttributeTargets.Field)]
    public class FieldAttr : PropertyAttribute
    {
        string m_sLabel;
        string m_sDetail;

        int m_iIndentLevel; // �༭��ģʽʹ��


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
        /// ����˵��
        /// </summary>
        public string Label { get { return m_sLabel; } }
        /// <summary>
        /// ��������ϸ������Ϣ
        /// </summary>
        public string Detail { get { return m_sDetail; } }
        /// <summary>
        /// ��Inspector�еĲ㼶
        /// </summary>
        public int IndentLevel { get { return m_iIndentLevel; } }
    }

}