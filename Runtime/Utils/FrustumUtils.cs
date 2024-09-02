using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ��׵�幤�߰�
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class FrustumUtils
    {
        /// <summary>
        /// ��ȡ�������׵Զ����� 4 ���˵�
        /// </summary>
        /// <param name="cam">�����</param>
        /// <returns>�˵����顣˳�������ǣ����¡����¡����ϡ�����</returns>
        static public Vector3[] GetCameraFarPlane4Points(Camera cam)
        {
            if (cam == null || cam.transform == null) { return null; }
            Transform camTransform = cam.transform;

            float farPlaneDistance = cam.farClipPlane;
            float upDistance = farPlaneDistance * Mathf.Tan(Mathf.Deg2Rad * cam.fieldOfView * 0.5f);
            float rightDistance = upDistance * cam.aspect;

            Vector3 up = camTransform.up * upDistance;
            Vector3 right = camTransform.right * rightDistance;
            Vector3 farPlaneCenterPoint = camTransform.position + camTransform.forward * farPlaneDistance;

            return new Vector3[4]
            {
            farPlaneCenterPoint - up - right, // ����
            farPlaneCenterPoint - up + right, // ����
            farPlaneCenterPoint + up - right, // ����
            farPlaneCenterPoint + up + right  // ����
            };
        }


        /// <summary>
        /// ��ȡ�������׵������� 4 ���˵�
        /// </summary>
        /// <param name="cam">�����</param>
        /// <returns>�˵����顣˳�������ǣ����¡����¡����ϡ�����</returns>
        static public Vector3[] GetCameraNearPlane4Points(Camera cam)
        {
            if (cam == null || cam.transform == null) { return null; }
            Transform camTransform = cam.transform;

            float nearPlaneDistance = cam.nearClipPlane;
            float upDistance = nearPlaneDistance * Mathf.Tan(Mathf.Deg2Rad * cam.fieldOfView * 0.5f);
            float rightDistance = upDistance * cam.aspect;

            Vector3 up = camTransform.up * upDistance;
            Vector3 right = camTransform.right * rightDistance;
            Vector3 nearPlaneCenterPoint = camTransform.position + camTransform.forward * nearPlaneDistance;

            return new Vector3[4]
            {
            nearPlaneCenterPoint - up - right, // ����
            nearPlaneCenterPoint - up + right, // ����
            nearPlaneCenterPoint + up - right, // ����
            nearPlaneCenterPoint + up + right  // ����
            };
        }



        /// <summary>
        /// ��ȡ�������׵��� 6 ��ƽ��
        /// </summary>
        /// <param name="cam">�����</param>
        /// <returns>ƽ�����顣˳�������ǣ����ҡ��¡��ϡ����á�Զ��</returns>
        static public Vector4[] GetCameraFrustumPlanes(Camera cam)
        {
            if (cam == null || cam.transform == null) { return null; }


            Transform t = cam.transform;
            Vector3 camPos = t.position;
            Vector3[] points = GetCameraFarPlane4Points(cam);
            Vector3 forward = t.forward;


            return new Vector4[6]
            {
#region ˳��������λ�ã�unity �ڲ�������˳ʱ��Ϊ����
            PlaneUtils.BuildPlane(camPos, points[0], points[2]), // ��
            PlaneUtils.BuildPlane(camPos, points[3], points[1]), // ��
            PlaneUtils.BuildPlane(camPos, points[1], points[0]), // ��
            PlaneUtils.BuildPlane(camPos, points[2], points[3]), // ��
#endregion
            PlaneUtils.BuildPlane(-forward, camPos + forward * cam.nearClipPlane), // ������
            PlaneUtils.BuildPlane(forward, camPos + forward * cam.farClipPlane)  // Զ����
            };
        }



        /// <summary>
        /// ��Χ���Ƿ�����׵��
        /// </summary>
        /// <param name="planes">��׵��6��</param>
        /// <param name="box">��Χ�еĶ���</param>
        /// <returns>true���ڣ�false������</returns>
        static public bool BoxInFrustum(Vector4[] planes, Vector3[] box)
        {
            // ��׵������� 6�� �ĺ����
            if (planes.Length != 6) { return false; }

            foreach (var plane in planes)
            {
                for (int i = 0; i < box.Length; i++)
                {
                    if (!(PlaneUtils.PointAzimuthWithPlane(box[i], plane) > 0))
                    {// ��ǰ��׵�ĺ���������Χ�е�ĳһ���㡣
                        break;
                    }
                    if (i == box.Length - 1)
                    {// ��Χ�����ж��㶼�ڵ�ǰ��׵����棨ͬһ��ƽ�棩֮�⣬�޳�
                        return false;
                    }
                }
            }
            return true;
        }



        /// <summary>
        /// ��Χ���Ƿ�����׵��
        /// </summary>
        /// <param name="planes">�����</param>
        /// <param name="box">��Χ�еĶ���</param>
        /// <returns>true���ڣ�false������</returns>
        static public bool BoxInFrustum(Camera cam, Vector3[] box)
        {
            if (cam == null) { return false; }

            // ��׵��6��
            Vector4[] planes = GetCameraFrustumPlanes(cam);
            if (planes == null || planes.Length == 0) { return false; }

            return BoxInFrustum(planes, box);
        }
    }
}