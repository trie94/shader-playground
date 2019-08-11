using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBehavior : MonoBehaviour
{
    [SerializeField]
    Transform target;
    Vector3 offset;

    void Start()
    {
        offset = transform.position - target.position;
    }

    // void LateUpdate()
    // {
    //     transform.position = target.position + offset;
    //     transform.LookAt(target.position);
    // }
}
