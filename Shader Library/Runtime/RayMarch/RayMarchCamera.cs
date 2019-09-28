using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Effects/Raymarch (Generic)")]
[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class RayMarchCamera : SceneViewFilter
{
    [SerializeField]
    private Shader shader;

    public Material RaymarchMat
    {
        get
        {
            if (!raymarchMat)
            {
                if (!shader) shader = Shader.Find("Hidden/RayMarch");
                raymarchMat = new Material(shader);
                raymarchMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return raymarchMat;
        }
    }
    private Material raymarchMat;

    public Camera Cam
    {
        get
        {
            if (!cam)
            {
                cam = GetComponent<Camera>();
            }
            return cam;
        }
    }
    private Camera cam;
    public float maxDist;

    public Vector4 sphere1;
    public Vector4 box1;
    public Vector4 sphere2;

    public float box1round;
    public float boxSphereSmooth;
    public float sphereIntersectSmooth;

    public float lightIntensity;
    public Vector2 shadowDistance;
    public float shadowIntensity;

    public Color mainColor;

    private void Awake()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
        if (!raymarchMat) raymarchMat = RaymarchMat;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!RaymarchMat)
        {
            Graphics.Blit(source, destination);
            return;
        }

        raymarchMat.SetMatrix("_CamFrustum", CamFrustum(Cam));
        raymarchMat.SetMatrix("_CamToWorld", cam.cameraToWorldMatrix);
        raymarchMat.SetFloat("_MaxDistance", maxDist);
        raymarchMat.SetVector("_Sphere1", sphere1);
        raymarchMat.SetVector("_Sphere2", sphere2);
        raymarchMat.SetVector("_Box1", box1);

        raymarchMat.SetFloat("_Box1Round", box1round);
        raymarchMat.SetFloat("_BoxSphereSmooth", boxSphereSmooth);
        raymarchMat.SetFloat("_SphereIntersectSmooth", sphereIntersectSmooth);

        raymarchMat.SetFloat("_LightIntensity", lightIntensity);
        raymarchMat.SetFloat("_ShadowDistance", shadowIntensity);
        raymarchMat.SetVector("_ShadowDistance", shadowDistance);


        raymarchMat.SetTexture("_MainTex", source);
        raymarchMat.SetColor("_MainColor", mainColor);

        RenderTexture.active = destination;
        GL.PushMatrix();
        GL.LoadOrtho();
        raymarchMat.SetPass(0);
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
