using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Path : MonoBehaviour
{
    #region path
    public Transform[] nodes;
    #endregion

    public Vector3 GetPoint(Transform[] p, float t)
    {
        List<Vector3> temp = new List<Vector3>();
        List<Vector3> res = new List<Vector3>();
        for (int i = 0; i < p.Length; i++)
        {
            temp.Add(p[i].position);
        }

        while (temp.Count != 1)
        {
            for (int i = 0; i < temp.Count - 1; i++)
            {
                res.Add(Bezier.GetPoint(temp[i], temp[i + 1], t));
            }
            temp.Clear();
            temp.AddRange(res);
            res.Clear();
        }
        return temp[0];
    }
}
