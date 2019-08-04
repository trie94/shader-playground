using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBehavior : MonoBehaviour
{
    [SerializeField]
    Transform target;

    void LateUpdate()
    {
        this.transform.RotateAround(target.position, Vector3.up, Time.deltaTime * 2);
    }
}
