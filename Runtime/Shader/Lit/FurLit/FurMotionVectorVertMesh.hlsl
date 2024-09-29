#ifndef FURMOTIONVECTORVERTMESH
#define FURMOTIONVECTORVERTMESH


// Available semantic start from TEXCOORD4
struct AttributesPass
{
    float3 previousPositionOS   : TEXCOORD4; // Contain previous transform position (in case of skinning for example)
#if defined (_ADD_PRECOMPUTED_VELOCITY)
    float3 precomputedVelocity  : TEXCOORD5; // Add Precomputed Velocity (Alembic computes velocities on runtime side).
#endif
};


struct VaryingsPassToPS
{
    // Note: Z component is not use currently
    // This is the clip space position. Warning, do not confuse with the value of positionCS in PackedVarying which is SV_POSITION and store in positionSS
    float4 positionCS;
    float4 previousPositionCS;
};

// Available interpolator start from TEXCOORD8
struct PackedVaryingsPassToPS
{
    // Note: Z component is not use
    float3 interpolators0 : TEXCOORD8;
    float3 interpolators1 : TEXCOORD9;
};

PackedVaryingsPassToPS PackVaryingsPassToPS(VaryingsPassToPS input)
{
    PackedVaryingsPassToPS output;
    output.interpolators0 = float3(input.positionCS.xyw);
    output.interpolators1 = float3(input.previousPositionCS.xyw);
    return output;
}

VaryingsPassToPS UnpackVaryingsPassToPS(PackedVaryingsPassToPS input)
{
    VaryingsPassToPS output;
    output.positionCS = float4(input.interpolators0.xy, 0.0, input.interpolators0.z);
    output.previousPositionCS = float4(input.interpolators1.xy, 0.0, input.interpolators1.z);
    return output;
}



#define VaryingsPassType VaryingsPassToPS
#define VARYINGS_NEED_PASS
#include "FurVertMesh.hlsl"



PackedVaryingsType MotionVectorVS(VaryingsType varyingsType, AttributesMesh inputMesh, AttributesPass inputPass)
{
    #if UNITY_REVERSED_Z
        varyingsType.vmesh.positionCS.z -= unity_MotionVectorsParams.z * varyingsType.vmesh.positionCS.w;
    #else
        varyingsType.vmesh.positionCS.z += unity_MotionVectorsParams.z * varyingsType.vmesh.positionCS.w;
    #endif


    varyingsType.vpass.positionCS = mul(UNITY_MATRIX_UNJITTERED_VP, float4(varyingsType.vmesh.positionRWS, 1.0));

    bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;
    if (forceNoMotion)
    {
        varyingsType.vpass.previousPositionCS = float4(0.0, 0.0, 0.0, 1.0);
    }
    else
    {
        bool previousPositionCSComputed = false;
        float3 effectivePositionOS = (float3)0.0f;
        float3 previousPositionRWS = (float3)0.0f;
        bool hasDeformation = unity_MotionVectorsParams.x > 0.0; 
        effectivePositionOS = (hasDeformation ? inputPass.previousPositionOS : inputMesh.positionOS);

        // See _TransparentCameraOnlyMotionVectors in HDCamera.cs
        #ifdef _WRITE_TRANSPARENT_MOTION_VECTOR
            if (_TransparentCameraOnlyMotionVectors > 0)
            {
                previousPositionRWS = varyingsType.vmesh.positionRWS.xyz;
                varyingsType.vpass.previousPositionCS = mul(UNITY_MATRIX_PREV_VP, float4(previousPositionRWS, 1.0));
                previousPositionCSComputed = true;
            }
        #endif

        if (!previousPositionCSComputed)
        {
            #if defined(HAVE_MESH_MODIFICATION)
                    AttributesMesh previousMesh = inputMesh;
                    previousMesh.positionOS = effectivePositionOS;
                    previousMesh = ApplyMeshModification(previousMesh, _LastTimeParameters.xyz);

                    // ECS
                    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(DOTS_DEFORMED)
                        ApplyPreviousFrameDeformedVertexPosition(inputMesh.vertexID, previousMesh.positionOS);
                    #endif

                    #if defined(_ADD_CUSTOM_VELOCITY) // For shader graph custom velocity
                            previousMesh.positionOS -= GetCustomVelocity(inputMesh);
                    #endif

                    #if defined(_ADD_PRECOMPUTED_VELOCITY)
                            previousMesh.positionOS -= inputPass.precomputedVelocity;
                    #endif

                    previousPositionRWS = TransformPreviousObjectToWorld(previousMesh.positionOS);
            #endif

            #ifdef ATTRIBUTES_NEED_NORMAL
                    float3 normalWS = TransformPreviousObjectToWorldNormal(inputMesh.normalOS);
            #else
                    float3 normalWS = float3(0.0, 0.0, 0.0);
            #endif
             
            #if defined(HAVE_VERTEX_MODIFICATION)
                    ApplyVertexModification(inputMesh, normalWS, previousPositionRWS, _LastTimeParameters.xyz);
            #endif
        }

        if (!previousPositionCSComputed)
        {
            varyingsType.vpass.previousPositionCS = mul(UNITY_MATRIX_PREV_VP, float4(previousPositionRWS, 1.0));
        }
    }

    return PackVaryingsType(varyingsType);
}


#endif //绒毛在运动模糊时需要的顶点结构及相关处理（由 Graphi 着色库工具生成）| 作者：强辰