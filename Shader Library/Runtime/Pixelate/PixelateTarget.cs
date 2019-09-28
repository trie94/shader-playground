using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelateTarget : MonoBehaviour
{
    private Renderer rend;
    public Renderer Renderer { get { return rend; } }
    public Material material;

    void Start()
    {
        rend = GetComponent<Renderer>();
        PixelateController.Instance.RegisterBlurTarget(this);
    }
}
