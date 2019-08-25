using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Camera[] cameras;
    public int cameraIndex;

    public static CameraController s_instance;
    public static CameraController Instance
    {
        get
        {
            if (s_instance == null)
            {
                s_instance = FindObjectOfType<CameraController>();
            }
            return s_instance;
        }
    }

    private void OnEnable()
    {
        InputManager.Instance.OnSwtichCamera += SwitchCamera;
        for (int i=0; i<cameras.Length; i++)
        {
            cameras[i].gameObject.SetActive(false);
        }
        cameras[0].gameObject.SetActive(true);
    }

    private void OnDisable()
    {
        if (InputManager.Instance != null)
        {
            InputManager.Instance.OnSwtichCamera -= SwitchCamera;
        }
    }

    private void SwitchCamera()
    {
        cameras[cameraIndex].gameObject.SetActive(false);
        cameraIndex = (cameraIndex + 1) % cameras.Length;
        cameras[cameraIndex].gameObject.SetActive(true);
    }
}
