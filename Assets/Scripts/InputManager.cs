using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

public class InputManager : MonoBehaviour
{
    static InputManager instance;
    public static InputManager Instance
    {
        get
        {
            if (instance == null)
            {
                instance = FindObjectOfType<InputManager>();
            }
            return instance;
        }
    }

    public Action OnMouseClick;

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            OnMouseClick?.Invoke();
        }
    }
}
