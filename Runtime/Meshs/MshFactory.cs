using System.Reflection;
using UnityEngine;

namespace com.graphi.renderhdrp
{
    /// <summary>
    /// ���񴴽�����
    /// <para>���ߣ�ǿ��</para>
    /// </summary>
    public class MshFactory
    {
        static private Mesh CreateMesh(string name)
        {
            return new Mesh() { name = name };
        }
        static private void SetData(ref Mesh msh, Vector3[] vertices, Vector2[] uv0s, int[] triangles, bool CalculateNormalAndTangent = true, bool CalculateBounds = true)
        {
            // ���ö���/uv0/�����档uv��ֵҪ���ڶ��㸳ֵ������ᱨuv���鳤���붥�����鳤�Ȳ�ƥ�����⡣
            msh.vertices = vertices;
            msh.uv = uv0s;
            msh.triangles = triangles;


            if (CalculateNormalAndTangent)
            {// ���㷨��/����
                msh.RecalculateNormals();
                msh.RecalculateTangents();
            }
            if (CalculateBounds)
            {// �����Χ��
                msh.RecalculateBounds();
            }
        }



        /// <summary>
        /// ����������Ķ���/uv/������
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="vertices">�������飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="uv0s">uv���飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="triangles">���������飨������Ҫ�ֶ���ʼ����</param>
        static public void Tetrahedrons(Vector3 layout, ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            float hx = layout.x * 0.5f;
            float hz = layout.z * 0.5f;
            float h = layout.y;

            vertices = new Vector3[5]
            {
            new Vector3(-hx, 0, -hz),
            new Vector3(-hx, 0, hz),
            new Vector3(hx, 0, hz),
            new Vector3(hx, 0, -hz),
            new Vector3(0, h, 0)
            };
            triangles = new int[18]
            {
            0,1,4,
            2,4,1,
            3,4,2,
            0,4,3,
            1,0,3,
            1,3,2
            };
            uv0s = new Vector2[5]
            {
            new Vector2(0,0),
            new Vector2(0,1),
            new Vector2(1,1),
            new Vector2(1,0),
            new Vector2(0.5f,0.5f)
            };
        }
        /// <summary>
        /// ������
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="CalculateNormalAndTangent">�Ƿ����¼��㷨��/����</param>
        /// <param name="CalculateBounds">�Ƿ����¼����Χ��</param>
        /// <returns>�������������</returns>
        static public Mesh Tetrahedrons(Vector3 layout, bool CalculateNormalAndTangent = true, bool CalculateBounds = true)
        {
            Mesh mesh = CreateMesh(MethodBase.GetCurrentMethod().Name);

            Vector3[] vertices = null;
            int[] triangles = null;
            Vector2[] uv0s = null;
            Tetrahedrons(layout, ref vertices, ref uv0s, ref triangles);

            SetData(ref mesh, vertices, uv0s, triangles, CalculateNormalAndTangent, CalculateBounds);

            return mesh;
        }





        /// <summary>
        /// �����Ľ��ǵĶ���/uv/������
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="vertices">�������飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="uv0s">uv���飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="triangles">���������飨������Ҫ�ֶ���ʼ����</param>
        static public void Shuriken(Vector4 layout, ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            float hw = layout.x * 0.5f;
            float hh = layout.y * 0.5f;
            float hmw = layout.z * 0.5f;
            float hmh = layout.w * 0.5f;

            float mwscale = hmw / hw;
            float mhscale = hmh / hh;

            vertices = new Vector3[9]
            {
            new Vector3(-hw, 0, 0),
            new Vector3(-hmw, hmh, 0),
            new Vector3(0, hh, 0),
            new Vector3(hmw, hmh, 0),
            new Vector3(hw, 0, 0),
            new Vector3(hmw, -hmh, 0),
            new Vector3(0, -hh, 0),
            new Vector3(-hmw, -hmh, 0),
            new Vector3(0, 0, 0)
            };
            triangles = new int[24]
            {
            0, 1, 8,
            1, 2, 8,
            2, 3, 8,
            3, 4, 8,
            4, 5, 8,
            5, 6, 8,
            6, 7, 8,
            7, 0, 8
            };
            uv0s = new Vector2[9]
            {
            new Vector2(0, 0.5f),
            new Vector2(0.5f * (1 - mwscale), 0.5f * (1 + mhscale)),
            new Vector2(0.5f, 1.0f),
            new Vector2(0.5f * (1 + mwscale),  0.5f * (1 + mhscale)),
            new Vector2(1.0f, 0.5f),
            new Vector2(0.5f * (1 + mwscale), 0.5f * (1 - mhscale)),
            new Vector2(0.5f, 0.0f),
            new Vector2(0.5f * (1 - mwscale), 0.5f * (1 - mhscale)),
            new Vector2(0.5f, 0.5f)
            };

        }
        /// <summary>
        /// �Ľ���
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="CalculateNormalAndTangent">�Ƿ����¼��㷨��/����</param>
        /// <param name="CalculateBounds">�Ƿ����¼����Χ��</param>
        /// <returns>�Ľ����������</returns>
        static public Mesh Shuriken(Vector4 layout, bool CalculateNormalAndTangent = true, bool CalculateBounds = true)
        {
            Mesh mesh = CreateMesh(MethodBase.GetCurrentMethod().Name);

            Vector3[] vertices = null;
            int[] triangles = null;
            Vector2[] uv0s = null;
            Shuriken(layout, ref vertices, ref uv0s, ref triangles);

            SetData(ref mesh, vertices, uv0s, triangles, CalculateNormalAndTangent, CalculateBounds);
            return mesh;
        }




        /// <summary>
        /// �������εĶ���/uv/������
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="vertices">�������飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="uv0s">uv���飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="triangles">���������飨������Ҫ�ֶ���ʼ����</param>
        static public void Lozenge(Vector3 layout, ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            float hl = layout.x * 0.5f; // x
            float hw = layout.y * 0.5f; // z
            float hh = layout.z * 0.5f; // y

            vertices = new Vector3[6]
            {
                new Vector3(-hl, 0, 0),
                new Vector3(0, 0, hw),
                new Vector3(hl, 0, 0),
                new Vector3(0, 0, -hw),
                new Vector3(0, hh, 0),
                new Vector3(0, -hh, 0)
            };
            triangles = new int[24]
            {
                0,4,3,
                3,4,2,
                2,4,1,
                1,4,0,
                0,3,5,
                3,2,5,
                2,1,5,
                1,0,5
            };
            uv0s = new Vector2[6]
            {
                new Vector2(0, 0.5f),
                new Vector2(0.5f, 0.5f),
                new Vector2(1, 0.5f),
                new Vector2(0.5f, 0.5f),
                new Vector2(0.5f, 1),
                new Vector2(0.5f, 0)
            };
        }
        /// <summary>
        /// ����
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="CalculateNormalAndTangent">�Ƿ����¼��㷨��/����</param>
        /// <param name="CalculateBounds">�Ƿ����¼����Χ��</param>
        /// <returns>Mesh����</returns>
        static public Mesh Lozenge(Vector3 layout, bool CalculateNormalAndTangent = true, bool CalculateBounds = true)
        {
            Mesh mesh = CreateMesh(MethodBase.GetCurrentMethod().Name);

            Vector3[] vertices = null;
            int[] triangles = null;
            Vector2[] uv0s = null;
            Lozenge(layout, ref vertices, ref uv0s, ref triangles);

            SetData(ref mesh, vertices, uv0s, triangles, CalculateNormalAndTangent, CalculateBounds);

            return mesh;
        }





        /// <summary>
        /// ����ƽ��Ķ���/uv/������
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="s">��Ԫ��ߴ�</param>
        /// <param name="vertices">�������飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="uv0s">uv���飨������Ҫ�ֶ���ʼ����</param>
        /// <param name="triangles">���������飨������Ҫ�ֶ���ʼ����</param>
        static public void Flat(Vector2Int layout, float s, ref Vector3[] vertices, ref Vector2[] uv0s, ref int[] triangles)
        {
            float size = Mathf.Max(0.000001f, s);
            int layoutX = Mathf.Max(1, layout.x);
            int layoutZ = Mathf.Max(1, layout.y);
            int vertsLayoutX = layoutX + 1;
            int vertsLayoutZ = layoutZ + 1;

            vertices = new Vector3[vertsLayoutX * vertsLayoutZ];
            uv0s = new Vector2[vertsLayoutX * vertsLayoutZ];
            triangles = new int[3 * 2 * layoutX * layoutZ];

            Vector3[] baseVertices = new Vector3[4]
            {
                new Vector3(0,0,0),
                new Vector3(size,0,0),
                new Vector3(size,0,size),
                new Vector3(0,0,size)
            };
            Vector2[] baseUV0s = new Vector2[]
            {
                new Vector2(0,0),
                new Vector2(1,0),
                new Vector2(1,1),
                new Vector2(0,1),
            };
            int[] baseTriangles = new int[]
            {
                0,3,1,
                1,3,2,
            };

            for (int x = 0; x < layoutX; x++)
            {// col
                for (int z = 0; z < layoutZ; z++)
                {// row
                 // �����ڶ��������е�����
                    int[] verticesIndexs = new int[4]
                    {
                   x + z * vertsLayoutX,
                   x + 1 + z * vertsLayoutX,
                   x + 1 + (z + 1) * vertsLayoutX,
                   x + (z + 1) * vertsLayoutX
                    };

                    // ���� / uv0
                    Vector3 vertOff = new Vector3(x * size, 0, z * size);
                    Vector2 uv0Off = new Vector2(x, z);
                    Vector2 uv0Cell = new Vector2(1 / (float)layoutX, 1 / (float)layoutZ);
                    for (int i = 0; i < 4; i++)
                    {
                        vertices[verticesIndexs[i]] = baseVertices[i] + vertOff;
                        //vertices[verticesIndexs[i]].y = 0; // �߶�
                        uv0s[verticesIndexs[i]] = (baseUV0s[i] + uv0Off) * uv0Cell;
                    }

                    // �����棨һ����Ƭ����2�������棩
                    int rectIndex = x + z * layoutX;
                    for (int j = 0; j < 2; j++)
                    {
                        int fragIndex = 2 * rectIndex + j;
                        for (int k = 0; k < 3; k++)
                        {
                            int pos = baseTriangles[j * 3 + k];
                            triangles[3 * fragIndex + k] = verticesIndexs[pos];
                        }
                    }
                }
            }
        }
        /// <summary>
        /// �����½�Ϊ��0��0��0�����ƽ��
        /// </summary>
        /// <param name="layout">����</param>
        /// <param name="s">��Ԫ��ߴ�</param>
        /// <param name="CalculateNormalAndTangent">�Ƿ����¼��㷨��/����</param>
        /// <param name="CalculateBounds">�Ƿ����¼����Χ��</param>
        /// <returns>Mesh�������</returns>
        static public Mesh Flat(Vector2Int layout, float s, bool CalculateNormalAndTangent = true, bool CalculateBounds = true)
        {
            Mesh mesh = CreateMesh(MethodBase.GetCurrentMethod().Name);

            Vector3[] vertices = null;
            Vector2[] uv0s = null;
            int[] triangles = null;
            Flat(layout, s, ref vertices, ref uv0s, ref triangles);

            SetData(ref mesh, vertices, uv0s, triangles, CalculateNormalAndTangent, CalculateBounds);

            return mesh;
        }

    }
}