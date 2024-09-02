using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;


#if UNITY_EDITOR
using UnityEditor;
#endif


namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 用于将形变数据应用到游戏对象的结构
    /// <para>作者：强辰</para>
    /// </summary>
    public class ApplyResult
    {
        /// <summary>
        /// 状态
        /// <para>true: 应用成功；false: 失败</para>
        /// </summary>
        public bool State { get; set; } = false;
        /// <summary>
        /// 错误信息
        /// <para>状态为true时，此值为空；否则，值为错误信息</para>
        /// </summary>
        public string Errmsg { get; set; } = string.Empty;
    }



    /// <summary>
    /// 用于存放对象所包含的混合形变信息结构数据
    /// <para>作者：强辰</para>
    /// </summary>
    [Serializable]
    public class BSDataGroup
    {
        /// <summary>
        /// 数据
        /// </summary>
        public BSData[] datas;


        /// <summary>
        /// 克隆
        /// </summary>
        /// <returns></returns>
        public BSDataGroup Clone()
        {
            if (this.datas == null) { return new BSDataGroup(); }

            BSDataGroup group = new BSDataGroup();
            int len = this.datas.Length;
            if (len == 0) { return new BSDataGroup(); }

            BSData[] newdata = new BSData[len];
            for (int i = 0; i < len; i++)
            {
                newdata[i] = this.datas[i].Clone();
            }
            group.datas = newdata;
            return group;
        }


        /// <summary>
        /// 释放
        /// </summary>
        public void Dispose()
        {
            if (datas == null) { return; }

            foreach (var data in datas)
                data.Dispose();
            Array.Clear(datas, 0, datas.Length);
            datas = null;
        }

        /// <summary>
        /// 转 Json
        /// </summary>
        /// <param name="json">包含所有的 BSData 数据结构的 Json 串</param>
        /// <returns></returns>
        static public string ToJson(string json)
        {
            return "{\"datas\":[ " + json + " ]}";
        }
    }


    /// <summary>
    /// 混合形变信息结构
    /// <para>作者：强辰</para>
    /// </summary>
    [Serializable]
    public class BSData
    {
        #region 对外属性
#if UNITY_EDITOR
        /// <summary>
        /// 所处网格的渲染器（用于 Editor 环境下方便处理问题）
        /// </summary>
        public SkinnedMeshRenderer m_SMR = null;
#endif
        /// <summary>
        /// 所处网格的名称
        /// </summary>
        public string m_MeshName = null;
        /// <summary>
        /// 形变名称（与 3DMax 或 Maya 中设定的名称一致）
        /// </summary>
        public string m_Name = null;
        /// <summary>
        /// 在网格下混合形变的索引
        /// </summary>
        public int m_Index = 0;
        /// <summary>
        /// 当前权重值
        /// </summary>
        public float m_Weight = 0.0f;

        // TODO: 最大、最小权重值目前 API 中没有可获取的方式
        //      https://docs.unity3d.com/cn/2019.4/Manual/BlendShapes.html 官方文档。
        //      文档解释 0：代表没有混合影响，100：最大混合影响。说明不管在3DMax、Maya等3D软件中如何设置范围，导入 unity 中都会被转成 [0,100] 的范围内。
        //      这里暂时写成常量类型，后续升级 unity 版本，看是否 unity 会增加额外的 API 来获取最小、最大权重值。
        public float m_WeightMin = 0.0f;
        public float m_WeightMax = 100.0f;
        // TODO: 结束
        #endregion


        const string Format_StringVal = "\"{0}\"";
        const string Format_KeyValue = "\"{0}\":{1},";

        /// <summary>
        /// 将数据转化为 Json 串
        /// </summary>
        /// <returns></returns>
        public string ToJson()
        {
            // 不使用此工具函数的原因是无法解决特殊的编译要求
            //return JsonUtility.ToJson(this);
            string json = "";

            FieldInfo[] fields = GetType().GetFields(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance);
            FieldInfo f;
            int len = fields.Length;
            for (int i = 0; i < len; i++)
            {
                f = fields[i];

                // 这里需要将权重最大、最小值排除, 具体说明在属性注释中. 另一个目的是为了减少转化 json 串的体积.
                if (f.Name == "m_WeightMin" || f.Name == "m_WeightMax") { continue; }

                Type t = f.FieldType;
                object val = f.GetValue(this);
                if (t == typeof(SkinnedMeshRenderer)) // 不参与编译 json 的属性
                    continue;
                else if (f.FieldType == typeof(string)) // 字符串类型
                    val = string.Format(Format_StringVal, val);

                // 累加
                json += string.Format(Format_KeyValue, f.Name, val);
            }

            json = json.Substring(0, json.Length - 1); // 删除最后一个逗号
            return "{" + json + "}";
        }


        /// <summary>
        /// 克隆
        /// </summary>
        public BSData Clone()
        {
            // 因为数据量较少，手动编写情况下性能最优。这里就不用反射机制处理了。
            BSData newdata = new BSData()
            {
#if UNITY_EDITOR
                m_SMR = this.m_SMR, // 这里直接引用
#endif
                // 克隆
                m_MeshName = this.m_MeshName,
                m_Name = this.m_Name,
                m_Index = this.m_Index,
                m_Weight = this.m_Weight,
                m_WeightMax = this.m_WeightMax,
                m_WeightMin = this.m_WeightMin
            };
            return newdata;
        }


        /// <summary>
        /// 释放
        /// </summary>
        public void Dispose()
        {
            m_Name = null;
            m_MeshName = null;
            m_Index = 0;
            m_Weight = 0.0f;
#if UNITY_EDITOR
            m_SMR = null;
#endif
        }
    }



    /// <summary>
    /// 混合形变控制器
    /// <para>作者：强辰</para>
    /// </summary>
    [ExecuteInEditMode]
    public class BlendShapesController : MonoBehaviour
    {
        #region 静态函数

        /// <summary>
        /// 获取参数节点及其所有子节点的混合变形信息（不包含未激活的对象）
        /// </summary>
        /// <param name="node">游戏对象</param>
        /// <returns>Dictionary 对象的 key 为模型网格名称，value 是其网格包含的所有形变信息数组</returns>
        static public Dictionary<string, BSData[]> GetDatas(GameObject node)
        {
            Dictionary<string, BSData[]> dic = new Dictionary<string, BSData[]>();
            SkinnedMeshRenderer[] smrs = node.transform.GetComponentsInChildren<SkinnedMeshRenderer>();
            if (smrs == null || smrs.Length == 0) { return dic; }

            Mesh msh;
            foreach (SkinnedMeshRenderer smr in smrs)
            {// 遍历所有的网格
                msh = smr.sharedMesh;
                if (msh == null) { continue; }
                int count = msh.blendShapeCount;
                if (count == 0) { continue; }

                dic[msh.name] = new BSData[count];
                for (int i = 0; i < count; i++)
                {// 拉取网格下所有的变形数据
                    dic[msh.name][i] = new BSData()
                    {
#if UNITY_EDITOR
                        m_SMR = smr,
#endif
                        m_MeshName = msh.name,
                        m_Name = msh.GetBlendShapeName(i),
                        m_Index = i,
                        m_Weight = smr.GetBlendShapeWeight(i)
                    };
                }
            }
            return dic;
        }



        /// <summary>
        /// 导出参数所包含的混合形变信息
        /// </summary>
        /// <param name="dic">数据</param>
        /// <returns>失败则返回null，成功则返回 json 格式的数据串</returns>
        static public string ExportData(Dictionary<string, BSData[]> dic)
        {
            if (dic == null || dic.Count == 0) { return null; }

            string json = "";
            BSData[] ary;
            int l;
            foreach (string k in dic.Keys)
            {
                ary = dic[k];
                l = ary.Length;
                for (int i = 0; i < l; i++)
                {
                    json += ary[i].ToJson() + ",";
                }
            }
            json = json.Substring(0, json.Length - 1);
            return BSDataGroup.ToJson(json);
        }


        /// <summary>
        /// 加载解析形变数据配置文件
        /// </summary>
        /// <param name="json">形变数据文件</param>
        /// <returns>如果失败，则返回null</returns>
        static public BSDataGroup LoadData(string json)
        {
            if (string.IsNullOrEmpty(json)) { return null; }
            BSDataGroup group = null;
            try
            {
                group = JsonUtility.FromJson<BSDataGroup>(json);
            }
            catch (Exception) { }
            return group;
        }



        /// <summary>
        /// 应用形变数据
        /// </summary>
        /// <param name="obj">游戏对象</param>
        /// <param name="jsondata">形变数据配置</param>
        static public ApplyResult Apply(GameObject obj, string jsondata)
        {
            if (obj == null || string.IsNullOrEmpty(jsondata))
            {
                return new ApplyResult() { Errmsg = "参数不正确!" };
            }
            SkinnedMeshRenderer[] smrs = obj.GetComponentsInChildren<SkinnedMeshRenderer>();
            if (smrs == null || smrs.Length == 0)
            {
                return new ApplyResult() { Errmsg = "对象未包含任何网格渲染器!" };
            }


            // 解析数据配置，并进行验证合法性
            BSDataGroup group = LoadData(jsondata);
            if (group == null)
            {
                return new ApplyResult() { Errmsg = "形变数据异常，请检查配置文件." };
            }
            BSData[] datas = group.datas;
            if (datas == null || datas.Length == 0)
            {
                return new ApplyResult() { Errmsg = "形变数据长度为0." };
            }

            // 应用形变数据
            foreach (BSData bsd in datas)
            {
                if (bsd == null) { continue; } // 形变数据是空值
                SkinnedMeshRenderer smr = FindSMR(smrs, bsd.m_MeshName);
                if (smr == null) { continue; } // 形变数据未包含在当前对象内
                if (bsd.m_Index > smr.sharedMesh.blendShapeCount - 1) { continue; } // 数据索引超出范围
                smr.SetBlendShapeWeight(bsd.m_Index, bsd.m_Weight);
            }

            group.Dispose();
            return new ApplyResult() { State = true };
        }



        /// <summary>
        /// 查找网格渲染器
        /// </summary>
        /// <param name="ary">网格渲染器数组</param>
        /// <param name="meshname">网格渲染器对应的网格名称</param>
        /// <returns></returns>
        static public SkinnedMeshRenderer FindSMR(SkinnedMeshRenderer[] ary, string meshname)
        {
            if (ary == null || ary.Length == 0) { return null; }
            if (string.IsNullOrEmpty(meshname)) { return null; }

            return Array.Find<SkinnedMeshRenderer>(ary, (smr) =>
            {
                if (smr == null || smr.sharedMesh == null) { return false; }
                return smr.sharedMesh.name == meshname;
            });
        }

        #endregion


        #region 组件
        [FieldAttr("混合形变数据配置")]
        public TextAsset m_BlendshapeConf = null;

#if UNITY_EDITOR
        private void OnValidate()
        {
            Set();
        }
#endif

        private void OnDestroy()
        {
            m_BlendshapeConf = null;
        }

        private void Start()
        {
            Set();
        }

        /// <summary>
        /// 设置数据
        /// <para>使用公共变量参数来设置</para>
        /// </summary>
        private void Set()
        {
            if (m_BlendshapeConf != null)
                Set(m_BlendshapeConf);
            else
            {
                if (Application.isPlaying) // 只在运行时才报告警告
                    Lg.Warn("混合形变数据配置为空! 若不需要配置来修改模型的混合形变，请移除此组件.");
#if UNITY_EDITOR
                Zero();
#endif
            }
        }
        /// <summary>
        /// 设置数据
        /// </summary>
        /// <param name="cnf">混合形变数据配置（Json 字符串格式）</param>
        public void Set(string cnf)
        {
            if (string.IsNullOrEmpty(cnf)) { Lg.Err("无法设置混合形变数据，数据为空（请查看配置文件内容）。"); }
            ApplyResult result = BlendShapesController.Apply(this.gameObject, cnf);
            if (!result.State)
            {
                Lg.Err(result.Errmsg);
                return;
            }
        }

        /// <summary>
        /// 设置数据
        /// </summary>
        /// <param name="cnf">混合形变数据配置</param>
        public void Set(TextAsset cnf)
        {
            if (cnf == null || cnf.dataSize == 0) { Lg.Err("配置为空或配置字节长度为0."); return; }
            Set(cnf.text);
        }


        /// <summary>
        /// 将当前对象所包含的混合形变数据全部归0（权重最小化）
        /// </summary>
        public void Zero()
        {
            try
            {
                SkinnedMeshRenderer[] smrs = GetComponentsInChildren<SkinnedMeshRenderer>();
                if (smrs == null || smrs.Length == 0) { return; }
                foreach (SkinnedMeshRenderer smr in smrs)
                {
                    if (smr == null || smr.sharedMesh == null) { continue; }
                    int len = smr.sharedMesh.blendShapeCount;
                    if (len == 0) { continue; }
                    for (int i = 0; i < len; i++)
                    {
                        smr.SetBlendShapeWeight(i, 0);
                    }
                }
            }
            catch (Exception e) { Lg.Err(e.Message); }
        }

        #endregion
    }



#if UNITY_EDITOR
    [CustomEditor(typeof(BlendShapesController))]
    internal class BlendShapesControllerEditor : Editor
    {
        BlendShapesController m_Src;
        List<Field> m_Lst = new List<Field>();

        GUIStyle BtnGUIStyle = null;
        GUIStyle LabelGUIStyle = null;
        bool m_Flag = true;


        private void OnEnable()
        {
            m_Src = (target as BlendShapesController);
            Tools.GetFieldInfo(typeof(BlendShapesController), serializedObject, ref m_Lst);
        }


        public override void OnInspectorGUI()
        {
            if (BtnGUIStyle == null)
                BtnGUIStyle = new GUIStyle("IN EditColliderButton") { richText = true, fontSize = 10 };
            if (LabelGUIStyle == null) { LabelGUIStyle = new GUIStyle("MiniLabel") { richText = true, fontSize = 11 }; }

            // 渲染Inspector元素
            serializedObject.Update();

            Tools.ShowFieldInfo(m_Lst);

            EditorGUILayout.Space(3);
            m_Flag = EditorGUILayout.Foldout(m_Flag, new GUIContent("操作（In Editor）"));
            if (m_Flag)
            {
                EditorGUILayout.BeginHorizontal("helpbox");
                EditorGUILayout.LabelField("<color=#999999>混合形变数据初始化还原<color=#ffcc00>（权重全部归0）</color>:</color> ", LabelGUIStyle, GUILayout.Width(230));
                if (GUILayout.Button("还原", BtnGUIStyle, GUILayout.Width(60), GUILayout.Height(18)))
                {
                    m_Src.m_BlendshapeConf = null;
                    m_Src.Zero();
                }
                EditorGUILayout.EndHorizontal();
            }

            // 应用并刷新
            serializedObject.ApplyModifiedProperties();
        }
    }
#endif

}