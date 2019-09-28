using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMove : MonoBehaviour
{
    public Vector3 velocity;
    public bool moveCamera;

    // Update is called once per frame
    void Update()
    {
        if (moveCamera)
            transform.transform.position += velocity;
    }
}
