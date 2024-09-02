using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// 视椎体工具包
    /// <para>作者：强辰</para>
    /// </summary>
    public class FrustumUtils
    {
        /// <summary>
        /// 获取摄像机视椎远裁面的 4 个端点
        /// </summary>
        /// <param name="cam">摄像机</param>
        /// <returns>端点数组。顺序依次是：左下、右下、左上、右上</returns>
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
            farPlaneCenterPoint - up - right, // 左下
            farPlaneCenterPoint - up + right, // 右下
            farPlaneCenterPoint + up - right, // 左上
            farPlaneCenterPoint + up + right  // 右上
            };
        }


        /// <summary>
        /// 获取摄像机视椎近裁面的 4 个端点
        /// </summary>
        /// <param name="cam">摄像机</param>
        /// <returns>端点数组。顺序依次是：左下、右下、左上、右上</returns>
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
            nearPlaneCenterPoint - up - right, // 左下
            nearPlaneCenterPoint - up + right, // 右下
            nearPlaneCenterPoint + up - right, // 左上
            nearPlaneCenterPoint + up + right  // 右上
            };
        }



        /// <summary>
        /// 获取摄像机视椎体的 6 个平面
        /// </summary>
        /// <param name="cam">摄像机</param>
        /// <returns>平面数组。顺序依次是：左、右、下、上、近裁、远裁</returns>
        static public Vector4[] GetCameraFrustumPlanes(Camera cam)
        {
            if (cam == null || cam.transform == null) { return null; }


            Transform t = cam.transform;
            Vector3 camPos = t.position;
            Vector3[] points = GetCameraFarPlane4Points(cam);
            Vector3 forward = t.forward;


            return new Vector4[6]
            {
#region 顺序针填入位置，unity 内部定义以顺时针为正面
            PlaneUtils.BuildPlane(camPos, points[0], points[2]), // 左
            PlaneUtils.BuildPlane(camPos, points[3], points[1]), // 右
            PlaneUtils.BuildPlane(camPos, points[1], points[0]), // 下
            PlaneUtils.BuildPlane(camPos, points[2], points[3]), // 上
#endregion
            PlaneUtils.BuildPlane(-forward, camPos + forward * cam.nearClipPlane), // 近裁面
            PlaneUtils.BuildPlane(forward, camPos + forward * cam.farClipPlane)  // 远裁面
            };
        }



        /// <summary>
        /// 包围盒是否在视椎内
        /// </summary>
        /// <param name="planes">视椎体6面</param>
        /// <param name="box">包围盒的顶点</param>
        /// <returns>true：在；false：不在</returns>
        static public bool BoxInFrustum(Vector4[] planes, Vector3[] box)
        {
            // 视椎体必须是 6面 的横截面
            if (planes.Length != 6) { return false; }

            foreach (var plane in planes)
            {
                for (int i = 0; i < box.Length; i++)
                {
                    if (!(PlaneUtils.PointAzimuthWithPlane(box[i], plane) > 0))
                    {// 当前视椎的横截面包含包围盒的某一顶点。
                        break;
                    }
                    if (i == box.Length - 1)
                    {// 包围盒所有顶点都在当前视椎检测面（同一个平面）之外，剔除
                        return false;
                    }
                }
            }
            return true;
        }



        /// <summary>
        /// 包围盒是否在视椎内
        /// </summary>
        /// <param name="planes">摄像机</param>
        /// <param name="box">包围盒的顶点</param>
        /// <returns>true：在；false：不在</returns>
        static public bool BoxInFrustum(Camera cam, Vector3[] box)
        {
            if (cam == null) { return false; }

            // 视椎体6面
            Vector4[] planes = GetCameraFrustumPlanes(cam);
            if (planes == null || planes.Length == 0) { return false; }

            return BoxInFrustum(planes, box);
        }
    }
}