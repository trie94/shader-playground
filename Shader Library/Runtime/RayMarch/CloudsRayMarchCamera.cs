using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CloudsRayMarchCamera : MonoBehaviour
{
    [SerializeField]
    private Shader cloudShader;

    public Material CloudMat
    {
        get
        {
            if (cloudMat == null)
            {
                cloudShader = Shader.Find("Hidden/Clouds");
                cloudMat = new Material(cloudShader);
                cloudMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return cloudMat;
        }
    }
    private Material cloudMat;
    private Camera cam;
    public Color lightColor1;
    public Color lightColor2;
    public Color cloudColor1;
    public Color cloudColor2;
    public float maxDist;
    public float lightColorIntensity;

    private void Awake()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
        cloudMat = new Material(cloudShader);
        if (!cloudMat) cloudMat = CloudMat;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!CloudMat)
        {
            Graphics.Blit(source, destination);
            return;
        }

        cloudMat.SetTexture("_MainTex", source);

        cloudMat.SetColor("_LightColor1", lightColor1);
        cloudMat.SetColor("_LightColor2", lightColor2);

        cloudMat.SetColor("_CloudBaseColor1", cloudColor1);
        cloudMat.SetColor("_CloudBaseColor2", cloudColor2);

        cloudMat.SetMatrix("_CamFrustum", CamFrustum(cam));
        cloudMat.SetMatrix("_CamToWorld", cam.cameraToWorldMatrix);
        cloudMat.SetFloat("_MaxDistance", maxDist);
        cloudMat.SetFloat("_LightIntensity", lightColorIntensity);

        RenderTexture.active = destination;
        GL.PushMatrix();
        GL.LoadOrtho();

        cloudMat.SetPass(0);
        GL.Begin(GL.QUADS);

        // start from bottom left
        GL.MultiTexCoord2(0, 0f, 0f);
        GL.Vertex3(0f, 0f, 3f);

        // bottom right
        GL.MultiTexCoord2(0, 1f, 0f);
        GL.Vertex3(1f, 0f, 2f);

        // top right
        GL.MultiTexCoord2(0, 1f, 1f);
        GL.Vertex3(1f, 1f, 1f);

        // top left
        GL.MultiTexCoord2(0, 0f, 1f);
        GL.Vertex3(0f, 1f, 0f);

        GL.End();
        GL.PopMatrix();
    }

    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fov = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);

        Vector3 goUp = Vector3.up * fov;
        Vector3 goRight = Vector3.right * fov * cam.aspect;

        Vector3 topLeft = (-Vector3.forward - goRight + goUp);
        Vector3 topRight = (-Vector3.forward + goRight + goUp);
        Vector3 bottomLeft = (-Vector3.forward - goRight - goUp);
        Vector3 bottomRight = (-Vector3.forward + goRight - goUp);

        frustum.SetRow(0, topLeft);
        frustum.SetRow(1, topRight);
        frustum.SetRow(2, bottomRight);
        frustum.SetRow(3, bottomLeft);

        return frustum;
    }
}
