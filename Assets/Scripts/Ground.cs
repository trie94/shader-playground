using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ground : MonoBehaviour
{
    Camera mainCamera;
    void Start()
    {
        mainCamera = Camera.main;
    }

    void Update()
    {
        Shader.SetGlobalMatrix("_World2Camera", mainCamera.worldToCameraMatrix);
    }
}
