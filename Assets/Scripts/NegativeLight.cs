using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
public class NegativeLight : MonoBehaviour
{
    Light negLight;
    void Start()
    {
        negLight = GetComponent<Light>();
        negLight.color = new Color(-0.7f, -0.7f, -0.7f, 1);
    }
}
