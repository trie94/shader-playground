using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Spawner : MonoBehaviour
{
    [SerializeField]
    GameObject seaCreaturePrefab;
    [SerializeField]
    float num = 10;
    [SerializeField]
    float spawnRad = 5f;
    [SerializeField]
    float height = 1f;

    List<GameObject> stones;

    // void Start()
    // {
    //     stones = new List<GameObject>();
    //     for (int i = 0; i < num; i++)
    //     {
    //         GameObject stone = Instantiate(seaCreaturePrefab, GetRandomPosFromPoint(Vector3.zero, spawnRad, height), Random.rotation);
    //         stone.transform.localScale = new Vector3(Random.Range(0.2f, 0.4f), Random.Range(0.1f, 0.3f), Random.Range(0.2f, 0.4f));

    //         stone.GetComponent<Renderer>().material.SetFloat("_NoiseFreq", Random.Range(0.3f, 0.5f));
    //         stone.GetComponent<Renderer>().material.SetFloat("_NoiseIntensity", Random.Range(1f, 2f));
    //         stones.Add(stone);
    //     }
    // }

    // void Update()
    // {
    //     for (int i=0; i<stones.Count; i++)
    //     {
    //         stones[i].transform.position = new Vector3(Mathf.Sin(Time.time), Mathf.Sin(Time.time * 0.5f) * 5, Mathf.Sin(Time.time));
    //     }
    // }

    Vector3 GetRandomPosFromPoint(Vector3 originPoint, float spawnRadius, float height)
    {
        var xz = Random.insideUnitCircle * spawnRadius;
        var y = Random.Range(-height, height);
        Vector3 spawnPos = new Vector3(xz.x, y, xz.y) + originPoint;

        return spawnPos;
    }
}
