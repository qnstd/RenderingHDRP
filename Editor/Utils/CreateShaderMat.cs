using System.IO;
using UnityEditor;
using UnityEngine;

namespace com.graphi.renderhdrp.editor
{
    /// <summary>
    /// 创建 Graphi 着色库中的材质球
    /// <para>作者：强辰</para>
    /// </summary>
    public class CreateShaderMat
    {
        /// <summary>
        /// 创建材质
        /// <para>直接以参数路径为保存路径，直接创建材质</para>
        /// </summary>
        /// <param name="p">材质保存路径（完整路径）</param>
        /// <param name="shadername">材质绑定的着色器</param>
        static public Material Excute2(string p, string shadername)
        {
            if (string.IsNullOrEmpty(p) || string.IsNullOrEmpty(shadername)) { return null; }
            Material mat = new Material(ShaderFind.GetTradition(shadername));
            AssetDatabase.CreateAsset(mat, p);
            AssetDatabase.Refresh();
            return mat;
        }


        /// <summary>
        /// 创建材质
        /// <para>需要在 Project 面板中手动选择目录后创建</para>
        /// </summary>
        /// <param name="shaderpath">材质使用的着色器路径</param>
        /// <param name="matname">材质文件名（不带文件后缀）</param>
        static public void Excute(string shaderpath, string matname)
        {
            if (!Tools.SelectDirectory(out string p)) { return; }
            p = Path.Combine(p, matname + ".mat").Replace("\\", "/");

            AssetDatabase.CreateAsset(new Material(ShaderFind.GetTradition(shaderpath)), p);
            AssetDatabase.Refresh();
        }


        #region FX
        [MenuItem("Assets/Graphi/Material/Transparent/Particle/Special")]
        static private void CreateParticleStandardMat()
        {
            Excute("Graphi/Fx/ParticleStandard", "ParticleStandard Material");
        }

        [MenuItem("Assets/Graphi/Material/Transparent/Particle/General")]
        static private void CreateParticleStandardToModelMat()
        {
            Excute("Graphi/Fx/ParticleStandardToModel", "ParticleStandardToModel Material");
        }


        [MenuItem("Assets/Graphi/Material/Transparent/Twist/Standard")]
        static private void CreateHotTwistMat()
        {
            Excute("Graphi/Fx/Twist", "HotTwist Material");
        }


        [MenuItem("Assets/Graphi/Material/Transparent/Twist/Vertex transformation")]
        static private void CreateHotTwistVertMat()
        {
            Excute("Graphi/Fx/TwistVert", "HotTwistVert Material");
        }

        [MenuItem("Assets/Graphi/Material/Transparent/Twist/Double perturbation transformation")]
        static private void CreateHotTwistDoubleMat()
        {
            Excute("Graphi/Fx/TwistDouble", "HotTwistDouble Material");
        }


        [MenuItem("Assets/Graphi/Material/Transparent/Lightning")]
        static private void CreateLightningMat()
        {
            Excute("Graphi/Fx/Lightning", "Lightning Material");
        }

        [MenuItem("Assets/Graphi/Material/Transparent/Fog")]
        static private void CreateFogMat()
        {
            Excute("Graphi/Fx/Fog", "Fog Material");
        }

        [MenuItem("Assets/Graphi/Material/Transparent/Bullet")]
        static private void CreateBulletMat()
        {
            Excute("Graphi/Fx/Bullet", "Bullet Material");
        }

        [MenuItem("Assets/Graphi/Material/Transparent/Shield")]
        static private void CreateShieldMat()
        {
            Excute("Graphi/Fx/Shield", "Shield Material");
        }

        [MenuItem("Assets/Graphi/Material/Transparent/RainDrop")]
        static private void CreateRainDropMat()
        {
            Excute("Graphi/Fx/RainDrop", "RainDrop Material");
        }
        #endregion

        #region 星球

        [MenuItem("Assets/Graphi/Material/Space/Atmosphere")]
        static private void CreatePlanet_AtmoSphere()
        {
            Excute("Graphi/Planet/Atmosphere", "Planet AtmoSphere Material");
        }

        [MenuItem("Assets/Graphi/Material/Space/Moon")]
        static private void CreatePlanet_Moon()
        {
            Excute("Graphi/Planet/Moon", "Moon Material");
        }

        [MenuItem("Assets/Graphi/Material/Space/Sun")]
        static private void CreatePlanet_Sun()
        {
            Excute("Graphi/Planet/Sun", "Sun Material");
        }

        [MenuItem("Assets/Graphi/Material/Space/CoronaStorm")]
        static private void CreatePlanet_SunCorona()
        {
            Excute("Graphi/Planet/CoronaStorm", "CoronaStorm Material");
        }

        [MenuItem("Assets/Graphi/Material/Space/Planet")]
        static private void CreatePlanet_Planetary()
        {
            Excute("Graphi/Planet/Planetary", "Planetary Material");
        }

        [MenuItem("Assets/Graphi/Material/Space/Ring")]
        static private void CreatePlanet_Ring()
        {
            Excute("Graphi/Planet/Ring", "Ring Material");
        }

        #endregion

        #region Lit

        [MenuItem("Assets/Graphi/Material/Lit/Standard")]
        static private void CreateLitStandardVari()
        {
            Excute("Graphi/Lit/LitStandardVariant", "LitStandardVariant Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/Standard Cover")]
        static private void CreateLitStandardCover()
        {
            Excute("Graphi/Lit/LitStandardCover", "LitStandardCover Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/Standard Iridescence And Cover")]
        static private void CreateLitIridescenceCover()
        {
            Excute("Graphi/Lit/LitIridescenceCover", "LitIridescenceCover Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/Layered")]
        static private void CreateLayeredLit()
        {
            Excute("Graphi/Lit/Layered", "LayeredLit Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/Normal permutation")]
        static private void CreateNormalDisplacement()
        {
            Excute("Graphi/Lit/NormalDisplacement", "NormalDisplacement Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/Normal fusion")]
        static private void CreateNormalBlend()
        {
            Excute("Graphi/Lit/NormalBlend", "NormalBlend Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/ClipColor")]
        static private void CreateClipColor()
        {
            Excute("Graphi/Lit/ClipColor", "ClipColor Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/ClipRGB")]
        static private void CreateClipRGB()
        {
            Excute("Graphi/Lit/ClipRGB", "ClipRGB Material");
        }

        [MenuItem("Assets/Graphi/Material/Lit/DecalHybrid")]
        static private void CreateDecalHybrid()
        {
            Excute("Graphi/Lit/DecalHybrid", "DecalHybrid Material");
        }

        #endregion

        #region Volume
        [MenuItem("Assets/Graphi/Material/Volume/OccDisplay")]
        static private void CreateOccDisplay()
        {
            Excute("Graphi/FullScreen/OccDisplay", "OccDisplay Material");
        }
        [MenuItem("Assets/Graphi/Material/Volume/CustomColorAndDepthBuffer")]
        static private void CreateDrawCustomObjectColorAndDepthBuffer()
        {
            Excute("Graphi/CustomPass/DrawCustomObjectColorAndDepthBuffer", "DrawCustomObjectColorAndDepth Material");
        }
        #endregion

        #region UI
        [MenuItem("Assets/Graphi/Material/UI/UiVFX")]
        static private void CreateUiVFXMat()
        {
            Excute("Graphi/UI/UiVFX", "UiVFX");
        }
        #endregion

        #region Other
        [MenuItem("Assets/Graphi/Material/Other/Video")]
        static private void CreateVideoMat()
        {
            Excute("Graphi/Unlit/Video", "Video Material");
        }
        #endregion
    }
}