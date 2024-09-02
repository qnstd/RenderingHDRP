using System;
using System.Collections.Generic;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 运行时用于着色器获取
    /// <para>作者：强辰</para>
    /// </summary>
    public class ShaderFind
    {
        /// <summary>
        /// Graphics Include 追加类型
        /// <para>作者：强辰</para>
        /// </summary>
        public enum E_GraInclude
        {
            Core,
            PostProcess,
            FullScreen,
            Sky
        }
        /// <summary>
        /// Graphics Include 追加项
        /// </summary>
        static public Dictionary<E_GraInclude, List<string>> C_GraIncludes = new Dictionary<E_GraInclude, List<string>>()
        {
            {E_GraInclude.Core, new List<string>()
            { 
                "Hidden/Graphi/FallbackErr" 
            } },
            {E_GraInclude.PostProcess, new List<string>()
            { 
                "Hidden/Graphi/PostProcess/Hue",
                "Hidden/Graphi/PostProcess/MotionBlur",
            } },
            {E_GraInclude.FullScreen, new List<string>()
            { 
                "Hidden/Graphi/FullScreen/Blur", 
                "Hidden/Graphi/FullScreen/Bloom", 
                "Hidden/Graphi/FullScreen/Gray",
                "Hidden/Graphi/FullScreen/Edges",
                "Hidden/Graphi/FullScreen/RadialBlur",
                "Hidden/Graphi/FullScreen/BlurWithMipmap",
            } },
            {E_GraInclude.Sky, new List<string>()
            { 
                "Hidden/Graphi/Sky/HDRI SkyFloat" 
            } },
        };


        /// <summary>
        /// 自定义后处理各节点插入项
        /// <para>key: 对应工程内设置的HD全局配置中的 Key</para>
        /// <para>value: 对应的节点插入项（自定义后处理类类型）列表</para>
        /// </summary>
        static public Dictionary<string, List<Type>> C_CustomPostProcessOrders = new Dictionary<string, List<Type>>()
        {
            {"beforeTransparentCustomPostProcesses", new List<Type>()
            {
            }
            }, //在透明之前（非透明和天空盒子之后）
            
            {"beforeTAACustomPostProcesses", new List<Type>()
            {
            } 
            }, //在TAA之前
            
            {"beforePostProcessCustomPostProcesses", new List<Type>()
            {
            }
            }, //在后处理之前
            
            {"afterPostProcessBlursCustomPostProcesses", new List<Type>()
            {
            } 
            }, //在后处理之后（Blurs）

            {"afterPostProcessCustomPostProcesses", new List<Type>()
            {
                typeof(Hue),
                typeof(MotionBlur),
            } 
            }, //在后处理之后
        };



        #region 接口
        /// <summary>
        /// 获取着色器（获取的着色器必须在GraphicsInclude列表中）
        /// </summary>
        /// <param name="index">索引</param>
        /// <param name="typ">类型</param>
        /// <returns></returns>
        static public Shader Get(int index, E_GraInclude typ)
        {
            C_GraIncludes.TryGetValue(typ, out List<string> lst);
            if(lst==null || lst.Count == 0) { return null; }
            if (index <0 || index > lst.Count - 1) { return null; }

            string s = lst[index];
            if (string.IsNullOrEmpty(s)) { return null; }

            //如果到这一步查找的结果还是null，说明对应的着色器文件未加入到GraphicsInclude里边
            return Shader.Find(s);
        }


        /// <summary>
        /// 获取着色器（获取的着色器必须在GraphicsInclude列表中）
        /// </summary>
        /// <param name="name">Shader路径</param>
        /// <param name="typ">类型</param>
        /// <returns></returns>
        static public Shader Get(string name, E_GraInclude typ)
        {
            if (string.IsNullOrEmpty(name)) { return null; }
            C_GraIncludes.TryGetValue(typ, out List<string> lst);
            if(lst == null || lst.Count == 0) { return null; }

            int indx = Array.IndexOf(lst.ToArray(), name);
            if(indx == -1) { return null; }

            //如果到这一步查找的结果还是null，说明对应的着色器文件未加入到GraphicsInclude里边
            return Shader.Find(name);
        }


        /// <summary>
        /// 获取着色器（Unity传统的获取方式。获取的着色器必须在GraphicsInclude或者被Resource目录下的任一材质引用。通过动态加载的Shader文件无法使用此方法进行获取！）
        /// </summary>
        /// <param name="name">shader 路径</param>
        /// <returns></returns>
        static public Shader GetTradition(string name)
        {
            if (string.IsNullOrEmpty(name)) { return null; }
            return Shader.Find(name);
        }
        #endregion
    }
}