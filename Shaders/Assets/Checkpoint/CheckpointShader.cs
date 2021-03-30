using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckpointShader : MonoBehaviour
{
    public float rotateSpeed;
    public Vector3 rotateDirection;

    private void Update()
    {
        transform.Rotate(rotateDirection * rotateSpeed * Time.deltaTime);
    }
}
