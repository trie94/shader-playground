using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshGenerator : MonoBehaviour
{
    private Square[,] squares;
    private ControlNode[,] controlNodes;
    private int nodeCountX = -1;
    private int nodeCountY = -1;
    private float mapWidth;
    private float mapHeight;

    private List<Vector3> vertices;
    private List<int> triangles;
    private Mesh mesh;
    private MeshFilter meshFilter;

    public void GenerateMesh(int[,] map, float squareSize, Ball[] balls)
    {
        meshFilter = GetComponent<MeshFilter>();
        mesh = new Mesh();
        vertices = new List<Vector3>();
        triangles = new List<int>();

        nodeCountX = map.GetLength(0);
        nodeCountY = map.GetLength(1);

        mapWidth = nodeCountX * squareSize;
        mapHeight = nodeCountY * squareSize;

        controlNodes = new ControlNode[nodeCountX, nodeCountY];

        for (int x = 0; x < nodeCountX; x++)
        {
            for (int y = 0; y < nodeCountY; y++)
            {
                for (int b = 0; b < balls.Length; b++)
                {
                    Vector3 pos = new Vector3(-mapWidth / 2 + x * squareSize + squareSize / 2, -mapHeight / 2 + y * squareSize + squareSize / 2, 0);
                    float inCircle = Mathf.Pow(balls[b].radius, 2) / (Mathf.Pow(pos.x - balls[b].center.x, 2) + Mathf.Pow(pos.y - balls[b].center.y, 2));
                    if (controlNodes[x, y] != null && controlNodes[x, y].active) continue;
                    controlNodes[x, y] = new ControlNode(pos, inCircle >= 1f, squareSize);
                }
            }
        }

        squares = new Square[nodeCountX - 1, nodeCountY - 1];
        for (int x = 0; x < nodeCountX - 1; x++)
        {
            for (int y = 0; y < nodeCountY - 1; y++)
            {
                squares[x, y] = new Square(controlNodes[x, y + 1], controlNodes[x + 1, y + 1], controlNodes[x + 1, y], controlNodes[x, y]);
                // TriangulateSquare(squares[x, y]);
            }
        }
        // meshFilter.mesh = mesh;
        // mesh.vertices = vertices.ToArray();
        // mesh.triangles = triangles.ToArray();
        // mesh.RecalculateNormals();
    }

    public void UpdateMesh(Ball[] balls, float squareSize)
    {
        if (balls != null)
        {
            Reset();

            for (int x = 0; x < nodeCountX; x++)
            {
                for (int y = 0; y < nodeCountY; y++)
                {
                    controlNodes[x, y].active = false;
                    controlNodes[x, y].vertexIndex = -1;
                    for (int b = 0; b < balls.Length; b++)
                    {
                        Vector3 pos = new Vector3(-mapWidth / 2 + x * squareSize + squareSize / 2, -mapHeight / 2 + y * squareSize + squareSize / 2, 0);
                        float inCircle = Mathf.Pow(balls[b].radius, 2) / (Mathf.Pow(pos.x - balls[b].center.x, 2) + Mathf.Pow(pos.y - balls[b].center.y, 2));
                        if (inCircle >= 1f)
                        {
                            controlNodes[x, y].active = true;
                        }
                        else
                        {
                            controlNodes[x, y].active |= false;
                        }
                    }
                }
            }

            for (int x = 0; x < nodeCountX - 1; x++)
            {
                for (int y = 0; y < nodeCountY - 1; y++)
                {
                    TriangulateSquare(squares[x, y]);
                }
            }

            meshFilter.mesh = mesh;
            mesh.vertices = vertices.ToArray();
            mesh.triangles = triangles.ToArray();
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();
        }
    }

    private void TriangulateSquare(Square square)
    {
        switch (square.configuration)
        {
            case 0:
                break;
            case 1:
                MeshFromPoints(square.bottomCenter, square.bottomLeft, square.leftCenter);
                break;
            case 2:
                MeshFromPoints(square.rightCenter, square.bottomRight, square.bottomCenter);
                break;
            case 3:
                MeshFromPoints(square.rightCenter, square.bottomRight, square.bottomLeft, square.leftCenter);
                break;
            case 4:
                MeshFromPoints(square.topCenter, square.topRight, square.rightCenter);
                break;
            case 5:
                MeshFromPoints(square.topCenter, square.topRight, square.rightCenter, square.bottomCenter, square.bottomLeft, square.leftCenter);
                break;
            case 6:
                MeshFromPoints(square.topCenter, square.topRight, square.bottomRight, square.bottomCenter);
                break;
            case 7:
                MeshFromPoints(square.topCenter, square.topRight, square.bottomRight, square.bottomLeft, square.leftCenter);
                break;
            case 8:
                MeshFromPoints(square.topLeft, square.topCenter, square.leftCenter);
                break;
            case 9:
                MeshFromPoints(square.topLeft, square.topCenter, square.bottomCenter, square.bottomLeft);
                break;
            case 10:
                MeshFromPoints(square.topLeft, square.topCenter, square.rightCenter, square.bottomRight, square.bottomCenter, square.leftCenter);
                break;
            case 11:
                MeshFromPoints(square.topLeft, square.topCenter, square.rightCenter, square.bottomRight, square.bottomLeft);
                break;
            case 12:
                MeshFromPoints(square.topLeft, square.topRight, square.rightCenter, square.leftCenter);
                break;
            case 13:
                MeshFromPoints(square.topLeft, square.topRight, square.rightCenter, square.bottomCenter, square.bottomLeft);
                break;
            case 14:
                MeshFromPoints(square.topLeft, square.topRight, square.bottomRight, square.bottomCenter, square.leftCenter);
                break;
            case 15:
                MeshFromPoints(square.topLeft, square.topRight, square.bottomRight, square.bottomLeft);
                break;
        }
    }

    private void MeshFromPoints(params Node[] points)
    {
        AssignVertices(points);
        if (points.Length >= 3) CreateTriangle(points[0], points[1], points[2]);
        if (points.Length >= 4) CreateTriangle(points[0], points[2], points[3]);
        if (points.Length >= 5) CreateTriangle(points[0], points[3], points[4]);
        if (points.Length >= 6) CreateTriangle(points[0], points[4], points[5]);
    }
    private void Reset()
    {
        triangles.Clear();
        vertices.Clear();
    }

    private void AssignVertices(Node[] points)
    {
        for (int i = 0; i < points.Length; i++)
        {
            // Debug.Log(vertices.Count);
            points[i].vertexIndex = vertices.Count;
            vertices.Add(points[i].position);
        }
    }

    private void CreateTriangle(Node a, Node b, Node c)
    {
        triangles.Add(a.vertexIndex);
        triangles.Add(b.vertexIndex);
        triangles.Add(c.vertexIndex);
    }

    // private void OnDrawGizmos()
    // {
    //     if (squares == null) return;

    //     for (int x = 0; x < squares.GetLength(0); x++)
    //     {
    //         for (int y = 0; y < squares.GetLength(1); y++)
    //         {
    //             Gizmos.color = (squares[x, y].topLeft.active) ? Color.red : Color.white;
    //             Gizmos.DrawCube(squares[x, y].topLeft.position, Vector3.one * 0.2f);

    //             Gizmos.color = (squares[x, y].topRight.active) ? Color.red : Color.white;
    //             Gizmos.DrawCube(squares[x, y].topRight.position, Vector3.one * 0.2f);

    //             Gizmos.color = (squares[x, y].bottomRight.active) ? Color.red : Color.white;
    //             Gizmos.DrawCube(squares[x, y].bottomRight.position, Vector3.one * 0.2f);

    //             Gizmos.color = (squares[x, y].bottomLeft.active) ? Color.red : Color.white;
    //             Gizmos.DrawCube(squares[x, y].bottomLeft.position, Vector3.one * 0.2f);

    //             Gizmos.color = Color.grey;
    //             Gizmos.DrawCube(squares[x, y].topCenter.position, Vector3.one * 0.1f);
    //             Gizmos.DrawCube(squares[x, y].rightCenter.position, Vector3.one * 0.1f);
    //             Gizmos.DrawCube(squares[x, y].bottomCenter.position, Vector3.one * 0.1f);
    //             Gizmos.DrawCube(squares[x, y].leftCenter.position, Vector3.one * 0.1f);
    //         }
    //     }
    // }

    public class Square
    {
        public ControlNode topLeft, topRight, bottomRight, bottomLeft;
        public Node topCenter, rightCenter, bottomCenter, leftCenter;
        public int configuration;

        public Square(ControlNode _topLeft, ControlNode _topright, ControlNode _bottomRight, ControlNode _bottomLeft)
        {
            topLeft = _topLeft;
            topRight = _topright;
            bottomRight = _bottomRight;
            bottomLeft = _bottomLeft;

            topCenter = topLeft.right;
            rightCenter = bottomRight.above;
            bottomCenter = bottomLeft.right;
            leftCenter = bottomLeft.above;

            if (topLeft.active) configuration += 8;
            if (topRight.active) configuration += 4;
            if (bottomRight.active) configuration += 2;
            if (bottomLeft.active) configuration += 1;
        }
    }

    public class Node
    {
        public Vector3 position;
        public int vertexIndex = -1;
        public Node(Vector3 _position)
        {
            position = _position;
        }
    }

    public class ControlNode : Node
    {
        public bool active;
        public Node above, right;

        public ControlNode(Vector3 _position, bool _active, float _squareSize) : base(_position)
        {
            active = _active;
            above = new Node(_position + Vector3.up * _squareSize / 2f);
            right = new Node(_position + Vector3.right * _squareSize / 2f);
        }
    }
}
