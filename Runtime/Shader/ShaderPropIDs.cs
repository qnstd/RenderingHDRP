namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 着色器使用的属性ID
    /// <para>作者：强辰</para>
    /// </summary>
    public class ShaderPropIDs
    {
        #region 表面
        public const string ID_AlbedoTex = "_AlbedoTex";
        public const string ID_AlbedoColor = "_Color";
        public const string ID_AlbedoUVTile = "_AlbedoUVTile";
        public const string ID_AlbedoTriBlendWeight = "_AlbedoTriBlendWeight";
        public const string ID_NormalTex = "_NormalTex";
        public const string ID_NormalStrength = "_NormalStrength";
        public const string ID_NormalUVTile = "_NormalUVTile";
        public const string ID_NormalTriBlendWeight = "_NormalTriBlendWeight";
        public const string ID_MaskTex = "_MaskTex";
        public const string ID_UseRemapping = "_UseRemapping";
        public const string ID_MetallicRemapping = "_MetalRemapping";
        public const string ID_SmoothRemapping = "_SmoothRemapping";
        public const string ID_AORemapping = "_AORemapping";
        public const string ID_Metallic = "_Metalness";
        public const string ID_Smooth = "_Smoothness";
        public const string ID_AOness = "_AOness";
        public const string ID_CoatTex = "_CoatMask";
        public const string ID_Coat = "_Coat";
        public const string ID_Alpha = "_Alp";
        public const string ID_TillingAndOffset = "_TillingAndOffset";
        #endregion


        #region 细节
        public const string ID_DetailTex = "_DetailTex";
        public const string ID_DetailNormalTex = "_DetailNormalTex";
        public const string ID_LockAlbedoTillingAndOffset = "_LockAlbedoTillingAndOffset";
        public const string ID_DetailTillingAndOffset = "_DetailTillingAndOffset";
        public const string ID_DetailAlbedoScal = "_DetailAlbedoScal";
        public const string ID_DetailNormalScal = "_DetailNormalScal";
        public const string ID_DetailSmoothnessScal = "_DetailSmoothnessScal";
        public const string ID_DetailColor = "_DetailColor";
        public const string ID_DetailForce = "_DetailForce";
        public const string ID_DetailPow = "_DetailPow";
        public const string ID_DetailUVTile = "_DetailUVTile";
        public const string ID_DetailBlendWeight = "_DetailBlendWeight";
        #endregion


        #region 自发光
        public const string ID_EmissionTex = "_EmissionTex";
        public const string ID_EmissionClr = "_EmissionClr";
        public const string ID_MultiplyAlbedo = "_MultiplyAlbedo";
        public const string ID_ExposureWeight = "_ExposureWeight";
        #endregion


        #region 菲涅尔边缘光
        public const string ID_FresnelColor = "_FresnelColor";
        public const string ID_FresnelArea = "_FresnelArea";
        public const string ID_FresnelForce = "_FresnelForce";
        public const string ID_FresnelOffset = "_FresnelOffset";
        #endregion


        #region 扭曲
        public const string ID_TwistTex = "_TwistTex";
        public const string ID_TwistUVTile = "_TwistUVTile";
        public const string ID_TwistSpeed = "_TwistSpeed";
        public const string ID_TwistForce = "_TwistForce";
        #endregion


        #region 光
        public const string ID_MainLightAttenFlag = "_MainLightAttenFlag";
        public const string ID_MainLightSensitivity = "_MainLightSensitivity";
        public const string ID_MainLightSensitivityPow = "_MainLightSensitivityPow";
        #endregion


        #region 覆盖色
        public const string ID_CoverMap = "_CoverMap";
        public const string ID_CoverFlag = "_CoverFlag";
        public const string ID_RFlag = "_RFlag";
        public const string ID_GFlag = "_GFlag";
        public const string ID_BFlag = "_BFlag";
        public const string ID_AFlag = "_AFlag";
        public const string ID_R = "_R";
        public const string ID_G = "_G";
        public const string ID_B = "_B";
        public const string ID_A = "_A";
        public const string ID_RBright = "_RBright";
        public const string ID_GBright = "_GBright";
        public const string ID_BBright = "_BBright";
        public const string ID_ABright = "_ABright";
        public const string ID_BlendFlag = "_BlendFlag";
        public const string ID_BlendType = "_BlendType";
        public const string ID_BlendFactor = "_BlendFactor";
        public const string ID_CoverThreshold = "_CoverThreshold";
        #endregion


        #region 通用
        public const string ID_UVSpeed = "_UVSpeed";
        public const string ID_MixedTex = "_MixedTex";
        public const string ID_Amplitude = "_Amplitude";
        public const string ID_TriUVTile = "_TriUVTile";
        public const string ID_TriBlendWeight = "_TriBlendWeight";
        public const string ID_Force = "_Force";
        #endregion
    }
}