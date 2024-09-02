using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 半透明合批优化
    /// <para>针对 ParticleSystem、LineRenderer、TrailRenderer 动态（Draw Dynamic）粒子合批</para>
    /// <para>作者：强辰</para>
    /// </summary>
    public class TranslucentBatch : MonoBehaviour
    {
        #region 全局变量、操作函数
        static private int OrderID = 0; // 累加 Order ID 值  （最大值：32767）
        static private List<int> OrderIds = new List<int>(); // 正在使用的的 Order ID 数组
        static private List<int> OldOrderIds = new List<int>(); // 曾经被使用过的 Order ID 数组
        static private Dictionary<string, int> Mat2ID = new Dictionary<string, int>(); // 当前正在维护的材质及对应的OrderID值
        static private Dictionary<string, List<int>> Mat2Objs = new Dictionary<string, List<int>>(); // 当前正在维护的材质及使用此材质的游戏对象的实例ID

        /// <summary>
        /// 获取排序ID
        /// </summary>
        /// <returns></returns>
        static private int GetOrderID()
        {
            int id;
            if (OldOrderIds.Count != 0)
            {// 存在曾经被用过的ID
                id = OldOrderIds[0]; // 弹出第一个ID
                OldOrderIds.RemoveAt(0);
                OrderIds.Add(id);
            }
            else
            {// 不存在，则直接累加
                ++OrderID;
                OrderIds.Add(OrderID);
                id = OrderID;
            }
            return id;
        }

        /// <summary>
        /// 信息
        /// </summary>
        /// <returns></returns>
        static public string Information()
        {
            return string.Format("TranslucentBatch ( OrderID = {0}, OrderIds Length = {1}, OrderIds Length（ever） = {2} )", OrderID, OrderIds.Count, OldOrderIds.Count);
        }

        /// <summary>
        /// 开启 Debug 输出
        /// </summary>
        static public bool EnableDebug { get; set; } = true;

        /// <summary>
        /// 输出、打印
        /// </summary>
        /// <param name="s"></param>
        /// <param name="iserr"></param>
        static private void Debugs(string s, bool iserr = false)
        {
            if (!EnableDebug) { return; }
            if (string.IsNullOrEmpty(s)) { return; }
            if (iserr)
                Debug.LogError(s);
        }
        #endregion




        Dictionary<string, List<int>> m_MatObjs = new Dictionary<string, List<int>>();


        // 移除
        private void Rem()
        {
            if (m_MatObjs == null || m_MatObjs.Count == 0) { return; }
            foreach (string key in m_MatObjs.Keys)
            {
                if (!Mat2Objs.ContainsKey(key))
                {
                    Debugs("TranslucentBatch【异常】：在执行移除材质的 OrderID 时，材质名作为索引未在全局维护组中找到，这是不可能出现的情况！", true);
                    continue;
                }
                Mat2Objs.TryGetValue(key, out List<int> list);

                List<int> lst = m_MatObjs[key];
                for (int i = 0; i < lst.Count; i++)
                {
                    list.Remove(lst[i]);
                }
                lst.Clear();
                // 判断当前key在全局数组中的值（数组长度）是否为0，如果是则清理
                if (list.Count == 0)
                {
                    // 清理材质对应的ID组及材质对应的渲染实例ID组
                    Mat2Objs.Remove(key);
                    int id = Mat2ID[key];
                    Mat2ID.Remove(key);
                    // 将id从正在使用的组中移除，并加入曾使用组中待下一次重用
                    OldOrderIds.Add(id);
                    OrderIds.Remove(id);
                }
            }
            m_MatObjs.Clear();
        }


        // 注册
        private void Reg(string matname, int instID, Renderer r)
        {
            // 从全局缓存中查找是否存在参数材质名称
            Mat2ID.TryGetValue(matname, out int id);
            if (id == 0)
            {// 不存在，添加新的材质
                id = GetOrderID();
                Mat2ID.Add(matname, id);
                Mat2Objs.Add(matname, new List<int>() { instID });
            }
            else
            {// 已存在相同的材质
                Mat2Objs.TryGetValue(matname, out List<int> l);
                l.Add(instID);
            }

            r.sortingOrder = id;
            m_MatObjs.TryGetValue(matname, out List<int> _l);
            if (_l == null)
            {
                _l = new List<int>();
                m_MatObjs.Add(matname, _l);
            }
            _l.Add(instID);
        }


        // 处理 ParticleSystem
        private void Analysis_ParticleSystem()
        {
            ParticleSystem[] pss = transform.GetComponentsInChildren<ParticleSystem>();
            for (int i = 0; i < pss.Length; i++)
            {
                ParticleSystem ps = pss[i];
                // 在 Hierarchy 列表中未激活
                bool b = ps.transform.gameObject.activeInHierarchy;
                if (!b) { continue; }
                // 不存在粒子渲染系统，或粒子渲染系统未开启
                ParticleSystemRenderer psr = ps.transform.GetComponent<ParticleSystemRenderer>();
                if (psr == null || !psr.enabled) { continue; }
                // 材质或材质引用的着色器为空
                Material mat = psr.sharedMaterial;
                if (mat == null || mat.shader == null)
                {
                    mat = psr.trailMaterial;
                    if (mat == null || mat.shader == null) { continue; }
                }

                Reg(mat.name, psr.GetInstanceID(), psr);
            }
        }


        // 处理 LineRenderer
        private void Analysis_LineRenderer()
        {
            LineRenderer[] lrs = transform.GetComponentsInChildren<LineRenderer>();
            for (int i = 0; i < lrs.Length; i++)
            {
                LineRenderer lr = lrs[i];
                if (!lr.enabled) { continue; }
                // 在 Hierarchy 列表中未激活
                bool b = lr.transform.gameObject.activeInHierarchy;
                if (!b) { continue; }
                // 不存在材质（lr下可支持材质组，但强制要求每个对象的材质组只允许绑定一个材质）
                Material mat = lr.sharedMaterial;
                if (mat == null || mat.shader == null) { continue; }

                Reg(mat.name, lr.GetInstanceID(), lr);
            }
        }


        // 处理 TrailRenderer
        private void Analysis_TrailRenderer()
        {
            TrailRenderer[] trs = transform.GetComponentsInChildren<TrailRenderer>();
            for (int i = 0; i < trs.Length; i++)
            {
                TrailRenderer tr = trs[i];
                if (!tr.enabled) { continue; }
                // 在 Hierarchy 列表中未激活
                bool b = tr.transform.gameObject.activeInHierarchy;
                if (!b) { continue; }
                // 不存在材质（lr下可支持材质组，但强制要求每个对象的材质组只允许绑定一个材质）
                Material mat = tr.sharedMaterial;
                if (mat == null || mat.shader == null) { continue; }

                Reg(mat.name, tr.GetInstanceID(), tr);
            }
        }



        /// <summary>
        /// 激活时
        /// </summary>
        private void OnEnable()
        {
            Analysis_ParticleSystem();
            Analysis_LineRenderer();
            Analysis_TrailRenderer();
            Debugs(Information());
        }


        /// <summary>
        /// 未激活或者移除
        /// </summary>
        private void OnDisable()
        {
            Rem();
            Debugs(Information());
        }


        /// <summary>
        /// 销毁
        /// </summary>
        private void OnDestroy()
        {
            m_MatObjs = null;
        }
    }

#if UNITY_EDITOR

    [CustomEditor(typeof(TranslucentBatch))]
    internal class TranslucentBatchEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            EditorGUILayout.HelpBox
            (
                "注意事项:\n" +
                "1. 此脚本应绑定在动态粒子所在的根节点游戏对象上，会自动处理根节点下所有的ParticleSystem、LineRenderer及TrailRenderer渲染组件；\n" +
                "2. 渲染组件所使用材质的名称应在工程内唯一，不可重复。同时，对于渲染组件支持材质组的，只允许材质组中包含一个材质；\n" +
                "3. 此脚本只在运行时触发并进行相关操作，不会影响在Editor模式下的任何操作；\n" +
                "4. 自动化处理是基于Unity渲染排序、合批操作的基础上进行分析并设置，能解决大部分动态粒子的合批，但也会存在少量无法进行合批；"
                , MessageType.Info
            );
        }
    }

#endif
}