using UnityEditor;

namespace com.graphi.renderhdrp
{

    /// <summary>
    /// 用于存储每个变量的信息（包含描述信息等）
    /// </summary>
    public struct Field
    {
#if UNITY_EDITOR
        public SerializedProperty Prop;
#endif
        public FieldAttr Attr;
    }


}