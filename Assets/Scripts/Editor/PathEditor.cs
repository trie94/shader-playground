using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Path))]
public class PathEditor : Editor
{
    private int lineSteps = 10;
    void OnSceneGUI()
    {
        Path path = target as Path;

        Transform handleTransform = path.transform;
        Handles.color = Color.white;

        Quaternion handleRotation = Tools.pivotRotation == PivotRotation.Local ?
			handleTransform.rotation : Quaternion.identity;

        Vector3 lineStart = path.nodes[0].position;
		for (int i = 1; i <= lineSteps; i++) {
			Vector3 lineEnd = path.GetPoint(path.nodes, i/(float)lineSteps);
			Handles.DrawLine(lineStart, lineEnd);
			lineStart = lineEnd;
		}
    }
}
