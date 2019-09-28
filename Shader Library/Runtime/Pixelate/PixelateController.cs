using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class PixelateController : MonoBehaviour
{
    private CommandBuffer commandBuffer;
    private Material pixelateMat;

    private int pixelatedTextureID;

    private List<PixelateTarget> targetObjects = new List<PixelateTarget>();

    private static PixelateController s_instance;
    public static PixelateController Instance
    {
        get
        {
            if (s_instance == null)
            {
                s_instance = FindObjectOfType<PixelateController>();
            }
            return s_instance;
        }
    }

    private void Awake()
    {
        s_instance = this;
        pixelatedTextureID = Shader.PropertyToID("_PixelatedTexture");

        commandBuffer = new CommandBuffer();
        commandBuffer.name = "pixelated buffer";

        GetComponent<Camera>().AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
    }

    private void BuildCommandBuffer()
    {
        commandBuffer.Clear();
        commandBuffer.GetTemporaryRT(pixelatedTextureID, Screen.width, Screen.height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, QualitySettings.antiAliasing);
        commandBuffer.SetRenderTarget(pixelatedTextureID);
        commandBuffer.ClearRenderTarget(true, true, Color.clear);

        for (int i = 0; i < targetObjects.Count; i++)
        {
            commandBuffer.DrawRenderer(targetObjects[i].Renderer, targetObjects[i].material);
        }
    }

    private void Update()
    {
        BuildCommandBuffer();
    }

    public void RegisterBlurTarget(PixelateTarget target)
    {
        targetObjects.Add(target);
    }
}
