using UnityEditor;

namespace com.graphi.renderhdrp
{

    /// <summary>
    /// ���ڴ洢ÿ����������Ϣ������������Ϣ�ȣ�
    /// </summary>
    public struct Field
    {
#if UNITY_EDITOR
        public SerializedProperty Prop;
#endif
        public FieldAttr Attr;
    }


}