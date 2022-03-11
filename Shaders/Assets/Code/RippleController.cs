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
        public float maxRippleHeight;
        public float rippleFalloff;
        public bool slowDown = false;
    }
    [Header("Ripple info")]
    public List<Ripples> ripples = new List<Ripples>();
    public float rippleSlowdown;
    public float rippleSpeedup;
    public int arrayLimits;
    [Header("Components")]
    public MeshRenderer rippleRenderer;

    private void Start()
    {
        //Set array limits.
        Vector4[] origins = new Vector4[arrayLimits];
        float[] frequencies = new float[arrayLimits];
        float[] heights = new float[arrayLimits];
        float[] fallOffs = new float[arrayLimits];
        rippleRenderer.material.SetVectorArray("_RippleOrigin", origins);
        rippleRenderer.material.SetFloatArray("_RippleFrequency", frequencies);
        rippleRenderer.material.SetFloatArray("_RippleHeight", heights);
        rippleRenderer.material.SetFloatArray("_RippleFalloff", fallOffs);

    }

    private void Update()
    {
        //Change ripple information.
        List<int> rippleRemoves = new List<int>();
        for (int i = 0; i < ripples.Count; i++)
        {
            if (ripples[i].slowDown)
            {
                ripples[i].rippleHeight -= rippleSlowdown * Time.deltaTime;
            }
            else
            {
                ripples[i].rippleHeight += rippleSpeedup * Time.deltaTime;
                if(ripples[i].rippleHeight > ripples[i].maxRippleHeight)
                {
                    ripples[i].slowDown = true;
                }
            }

            if(ripples[i].rippleHeight < 0)
            {
                rippleRemoves.Add(i);
            }
        }
        //Remove all unwanted ripples.
        for (int i = rippleRemoves.Count - 1; i >= 0; i--)
        {
            ripples.Remove(ripples[rippleRemoves[i]]);
        }

        //Set ripple information in material.
        if(ripples.Count > 0)
        {
            Vector4[] origins = new Vector4[ripples.Count];
            float[] frequencies = new float[ripples.Count];
            float[] heights = new float[ripples.Count];
            float[] fallOffs = new float[ripples.Count];
            for (int i = 0; i < ripples.Count; i++)
            {
                origins[i] = new Vector4(ripples[i].impactOrigins.x, 0, ripples[i].impactOrigins.z, 0);
                frequencies[i] = ripples[i].rippleFrequency;
                heights[i] = ripples[i].rippleHeight;
                fallOffs[i] = ripples[i].rippleFalloff;
            }



            rippleRenderer.material.SetVectorArray("_RippleOrigin", origins);
            rippleRenderer.material.SetInt("_RippleOriginCount", ripples.Count);
            rippleRenderer.material.SetFloatArray("_RippleFrequency", frequencies);
            rippleRenderer.material.SetFloatArray("_RippleHeight", heights);
            rippleRenderer.material.SetFloatArray("_RippleFalloff", fallOffs);
        }
    }

    public void AddRipple(Vector3 rippleLocation, float rippleFrequency, float rippleHeight, float rippleFalloff)
    {
        Ripples newRipple = new Ripples();
        Vector3 newPos = rippleLocation - transform.position;
        newPos = new Vector3(newPos.x / transform.localScale.x, newPos.y / transform.localScale.y, newPos.z / transform.localScale.z);
        newRipple.impactOrigins = newPos;
        newRipple.rippleFrequency = rippleFrequency;
        newRipple.maxRippleHeight = rippleHeight;
        newRipple.rippleFalloff = rippleFalloff;

        ripples.Add(newRipple);
    }
}
