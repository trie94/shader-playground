using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lighty : MonoBehaviour
{
    [SerializeField]
    Transform mainBody;

    [SerializeField]
    Transform subBody;

    [SerializeField]
    Transform tail;

    Vector3 target;
    bool isClicked;

    Camera mainCamera;
    
    void Start()
    {
        InputManager.Instance.OnMouseClick += UpdateTarget;
        mainCamera = Camera.main;
    }

    void Update()
    {
        float distSq = (mainBody.position - target).sqrMagnitude;
        if (distSq > 0.1f)
        {
            mainBody.position = Vector3.Lerp(mainBody.position, target, 0.04f);
        }

        float distSqBetweenBodies = (mainBody.position - target).sqrMagnitude;
        if (distSqBetweenBodies > 0.05f)
        {
            subBody.position = Vector3.Lerp(subBody.position, mainBody.position, 0.5f);
            tail.position = Vector3.Lerp(tail.position, subBody.position, 0.3f);
        }
    }

    void UpdateTarget()
    {
        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            target = hit.point;
        }
    }

    void OnDisable()
    {
        if (InputManager.Instance!= null) 
        {
            InputManager.Instance.OnMouseClick -= UpdateTarget;
        }
    }
}
