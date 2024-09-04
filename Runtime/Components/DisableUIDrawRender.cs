using UnityEngine.UI;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 禁止UI组件的渲染
    /// <para>作者：强辰</para>
    /// </summary>
    public class DisableUIDrawRender : Graphic
    {
        /// <summary>
        /// 覆盖默认渲染
        /// </summary>
        /// <param name="update"></param>
        public override void Rebuild(CanvasUpdate update) { /** 不绘制任何像素 */}
    }
}