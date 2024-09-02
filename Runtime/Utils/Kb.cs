using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 键盘操作
    /// <para>作者：强辰</para>
    /// </summary>
    public class Kb
    {
        static public void Run()
        {

#if UNITY_EDITOR || UNITY_STANDALONE_WIN // 编辑器及Windows
            if (Input.GetKeyDown(KeyCode.BackQuote))
            {// 键盘1左侧位[ ` ]
                BackQuote();
            }
#endif
        }



        static private int s_ShowOrder = -1;
        static private void BackQuote()
        {
            s_ShowOrder++;
            switch (s_ShowOrder)
            {
                case 0:
                    RuntimePerformance.DrawFlag = true;
                    TextureStreamingGraphics.DrawFlag = false;
                    break;
                case 1:
                    RuntimePerformance.DrawFlag = false;
                    TextureStreamingGraphics.DrawFlag = true;
                    break;
                case 2:
                    RuntimePerformance.DrawFlag = false;
                    TextureStreamingGraphics.DrawFlag = false;
                    s_ShowOrder = -1;
                    break;
            }
        }

    }

}