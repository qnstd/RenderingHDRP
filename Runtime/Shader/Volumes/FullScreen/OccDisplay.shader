/*
    被遮挡物的绘制

    渲染管线：
        High-Definition RenderPipeline

    作者：强辰
*/
Shader "Graphi/FullScreen/OccDisplay"
{

    Properties
    {
        [HDR]_Color("Color", Color) = (1,1,1,1)
        _Tex("Tex", 2D) = "white"{}
    }

    HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"


    
    float4 _Color; // 颜色
    TEXTURE2D(_Tex); // 纹理
    SAMPLER(sampler_Tex);
    float4 _Tex_ST;


    // 实现
    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        //float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        
        // 读取自定义的深度图及颜色缓冲
        float2 uv = varyings.positionCS.xy;
        float4 cc = CustomPassLoadCustomColor(uv);
        float d = LoadCustomDepth(uv);

        // 计算被遮挡时显示的颜色
        float alpFactor = (depth > d + 0.000001) ? 1 : 0;
        float4 oc = _Color * SAMPLE_TEXTURE2D_X_LOD(_Tex, sampler_Tex, TRANSFORM_TEX(posInput.positionNDC * _RTHandleScale.xy, _Tex), 0);
        oc.a *= alpFactor;

        // 由于自定义颜色缓冲以黑色为背景，前景色为白色，那么在后续进行混合颜色时，黑色部分并不会是透明的，所以这里需要将黑色部分转为透明.
        float factor = step(0.1, Luminance(cc.rgb));// ( c.r*c.g*c.b*c.a == 0 ) ? 0 : 1;
        cc *= factor;

        // 混合颜色
        return oc * cc;
    }

    ENDHLSL


    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Occlusion Display"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}