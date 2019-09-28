using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Ball
{
    public Vector3 center;
    public float radius;
    public Vector3 velocity;

    public Ball(Vector3 _center, float _radius)
    {
        center = _center;
        radius = _radius;
    }
}

public class Metaball : MonoBehaviour
{
    public static Metaball s_instance;
    public static Metaball Instance
    {
        get
        {
            if (s_instance == null)
            {
                s_instance = FindObjectOfType<Metaball>();
            }
            return s_instance;
        }
    }

    private MeshGenerator meshGen;
    private int[,] map;
    [SerializeField]
    private int width = 5;
    [SerializeField]
    private int height = 5;
    [SerializeField]
    private int numOfBalls = 5;
    [SerializeField]
    private float gridSize = 0.5f;

    [SerializeField]
    private float pickTime = 0.4f;
    public Ball[] metaballs;
    [SerializeField]
    private float velocity = 0.2f;

    private void Awake()
    {
        meshGen = GetComponent<MeshGenerator>();
        map = new int[width, height];
        metaballs = new Ball[numOfBalls];
        InitBalls();

        meshGen.GenerateMesh(map, gridSize, metaballs);
    }

    private void Update()
    {
        MoveBalls();
        meshGen.UpdateMesh(metaballs, gridSize);
    }

    private void InitBalls()
    {
        for (int i=0; i<numOfBalls; i++)
        {
            Vector3 center = Random.insideUnitCircle * width * gridSize /2f;
            float rad = Random.Range(0.5f, 2f);
            Ball ball = new Ball(center, rad);
            ball.velocity = new Vector3(Random.Range(0.5f, 2f), Random.Range(0.5f, 2f), 0f);
            metaballs[i] = ball;
        }
    }

    private void MoveBalls()
    {
        for (int i = 0; i < numOfBalls; i++)
        {
            Ball ball = metaballs[i];
            ball.center += ball.velocity;

            if (ball.center.x - ball.radius < -width * gridSize /2f)
            {
                ball.velocity.x = velocity;
            }
            if (ball.center.x + ball.radius > width * gridSize /2f)
            {
                ball.velocity.x = -velocity;
            }
            if (ball.center.y - ball.radius < -height * gridSize /2f)
            {
                ball.velocity.y = velocity;
            }
            if (ball.center.y + ball.radius > height * gridSize /2f)
            {
                ball.velocity.y = -velocity;
            }
        }
    }

    private void OnDrawGizmos()
    {
        if (metaballs != null)
        {
            for (int i = 0; i < metaballs.Length; i++)
            {
                Gizmos.DrawSphere(metaballs[i].center, metaballs[i].radius);
            }
        }
    }
}
