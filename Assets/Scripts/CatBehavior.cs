using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatBehavior : MonoBehaviour
{
    [Header("legs")]
    [SerializeField]
    Transform frontLeft;
    [SerializeField]
    Transform frontRight;
    [SerializeField]
    Transform backLeft;
    [SerializeField]
    Transform backRight;

    [Header("tails")]

    [SerializeField]
    Transform tailCore;
    [SerializeField]
    Transform tail1;
    [SerializeField]
    Transform tail2;
    [SerializeField]
    Transform tail3;
    [SerializeField]

    [Header("head")]

    Transform head;

    [SerializeField]
    Transform leftEar;
    [SerializeField]
    Transform rightEar;

    [Header("face animation")]

    [SerializeField]
    GameObject body;
    [SerializeField]
    Texture2D[] faceTextures;

    [SerializeField]
    float speed = 1f;

    [SerializeField]
    float tailSpeed = 0.5f;

    float rotationValue = 25f;
    float frontLeftOriginalAngle;
    float frontRightOriginalAngle;
    float backLeftOriginalAngle;
    float backRightOriginalAngle;
    float tailCoreOriginalAngle;
    float tail1OriginalAngle;
    float tail2OriginalAngle;
    float tail3OriginalAngle;

    Renderer bodyRenderer;

    void Start()
    {
        frontLeftOriginalAngle = frontLeft.localEulerAngles.z;
        frontRightOriginalAngle = frontRight.localEulerAngles.z;
        backLeftOriginalAngle = backLeft.localEulerAngles.z;
        backRightOriginalAngle = backRight.localEulerAngles.z;
        tailCoreOriginalAngle = tailCore.localEulerAngles.z;
        tail1OriginalAngle = tail1.localEulerAngles.z;
        tail2OriginalAngle = tail2.localEulerAngles.z;
        tail3OriginalAngle = tail3.localEulerAngles.z;

        bodyRenderer = body.GetComponent<Renderer>();
        StartCoroutine(PlayFaceAnim());
    }

    void Update()
    {

    }

    void LateUpdate()
    {
        rotateLeg(frontLeft, frontLeftOriginalAngle);
        rotateLeg(frontRight, frontRightOriginalAngle);
        rotateLeg(backLeft, backLeftOriginalAngle, -1f);
        rotateLeg(backRight, backRightOriginalAngle, -1f);

        // tail
        tailCore.rotation = Quaternion.Euler(tailCore.localEulerAngles.x, tailCore.localEulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue * 0.5f) + tailCoreOriginalAngle);
        tail1.localRotation = Quaternion.Euler(tail1.localEulerAngles.x, tail1.localEulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue * 0.75f) + tail1OriginalAngle);
        tail2.localRotation = Quaternion.Euler(tail2.localEulerAngles.x, tail2.localEulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue * 0.95f) + tail2OriginalAngle);
        tail3.localRotation = Quaternion.Euler(tail3.localEulerAngles.x, tail3.localEulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue) + tail3OriginalAngle);

        // head
        head.rotation = Quaternion.Euler(head.localEulerAngles.x, head.localEulerAngles.y, Mathf.Sin(Mathf.PI * Time.time * speed) * rotationValue * 0.5f);

        // ears

        // face anim
        // bodyMaterial.SetTexture("_MainTex", face2);
    }

    void rotateLeg(Transform target, float targetOriginalAngle, float back = 1f)
    {
        target.rotation = Quaternion.Euler(target.localEulerAngles.x, target.localEulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * speed * back) * rotationValue) + targetOriginalAngle);
    }

    IEnumerator PlayFaceAnim()
    {
        float defaultFace = 1f;
        for (int i = 0; i < faceTextures.Length; i++)
        {
            bodyRenderer.material.SetTexture("_MainTex", faceTextures[i]);
            if (i == faceTextures.Length - 1) i = -1;
            defaultFace = (i == 0) ? 20f : 1f;
            yield return new WaitForSeconds(0.1f * defaultFace);
        }
    }
}
