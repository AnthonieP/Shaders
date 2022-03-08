using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleController : MonoBehaviour
{
    [System.Serializable]
    public class Ripples
    {
        public Vector3 impactOrigins;
        public float rippleFrequency;
        public float rippleHeight;
    }
    public List<Ripples> ripples = new List<Ripples>();
    public MeshRenderer rippleRenderer;

    private void Update()
    {
        if(ripples.Count > 0)
        {
            Vector4[] origins = new Vector4[ripples.Count];
            for (int i = 0; i < ripples.Count; i++)
            {
                origins[i] = new Vector4(ripples[i].impactOrigins.x, 0, ripples[i].impactOrigins.z, 0);
            }
            rippleRenderer.material.SetVectorArray("_RippleOrigin", origins);
            rippleRenderer.material.SetInt("_RippleOriginCount", ripples.Count);
        }
    }
}
