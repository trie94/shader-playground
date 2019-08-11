using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatBehavior : MonoBehaviour
{
    #region animation
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
    #endregion
    #region path

    [SerializeField]
    private int lineSteps = 10;
    private float progress = 0f;
    [SerializeField]
    private float duration = 10f;

    [SerializeField]
    Path path;
    #endregion

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
        progress += Time.deltaTime / duration;
		if (progress > 1f) progress = 0f;

        Vector3 target = path.GetPoint(path.nodes, progress);
        Vector3 lookDir = target - transform.position;
        Quaternion rotation = Quaternion.LookRotation(lookDir, Vector3.up);

        transform.rotation = rotation;
		transform.position = target;
    }

    void LateUpdate()
    {
        // transform.position = Vector3.Lerp(transform.position, pathNodes[0].position, 0.01f);
        // Vector3 forward = (pathNodes[0].position - transform.position).normalized;
        // transform.rotation = Quaternion.LookRotation(forward);

        rotateLimb(frontLeft, frontLeftOriginalAngle, speed);
        rotateLimb(frontRight, frontRightOriginalAngle, speed);
        rotateLimb(backLeft, backLeftOriginalAngle, speed, -1f);
        rotateLimb(backRight, backRightOriginalAngle, speed, -1f);

        // tail
        tailCore.rotation = Quaternion.Euler(tailCore.eulerAngles.x, tailCore.eulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue * 0.5f) + tailCoreOriginalAngle);
        tail1.rotation = Quaternion.Euler(tail1.eulerAngles.x, tail1.eulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue * 0.75f) + tail1OriginalAngle);
        tail2.rotation = Quaternion.Euler(tail2.eulerAngles.x, tail2.eulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue * 0.95f) + tail2OriginalAngle);
        tail3.rotation = Quaternion.Euler(tail3.eulerAngles.x, tail3.eulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * tailSpeed) * rotationValue) + tail3OriginalAngle);

        // head
        head.rotation = Quaternion.Euler(head.eulerAngles.x, head.eulerAngles.y, Mathf.Sin(Mathf.PI * Time.time * speed) * rotationValue * 0.5f);
    }

    void rotateLimb(Transform target, float targetOriginalAngle, float speed, float back = 1f)
    {
        target.rotation = Quaternion.Euler(target.eulerAngles.x, target.eulerAngles.y, (Mathf.Sin(Mathf.PI * Time.time * speed * back) * rotationValue) + targetOriginalAngle);
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

    // public Vector3 GetPoint (Vector3 p0, Vector3 p1, Vector3 p2, float t) {
	// 	return Bezier.GetPoint(p0, p1, p2, t);
	// }
}
