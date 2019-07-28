﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Light : MonoBehaviour
{
    [SerializeField]
    GameObject cat;

    void Update()
    {
        transform.RotateAround(transform.position, cat.transform.up, 100*Time.deltaTime);
    }
}