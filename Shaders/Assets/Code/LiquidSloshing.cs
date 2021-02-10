using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LiquidSloshing : MonoBehaviour
{
    public Renderer liquidRenderer;
    public float sloshingHightIntensity;
    public float sloshingIntensity;
    public float maxSloshing;
    public float velocitySlowdownMultiplier;
    Vector3 velocity;
    Vector3 lastPos;

    private void Start()
    {
        lastPos = transform.position;
    }

    private void Update()
    {
        CalculateSloshing();
    }

    void CalculateSloshing()
    {
        velocity += (lastPos - transform.position) * Time.deltaTime;
        velocity *= velocitySlowdownMultiplier;
        if(velocity.x > 0)
        {
            velocity.x = Mathf.Min(velocity.x, maxSloshing);
        }
        else
        {
            velocity.x = Mathf.Max(velocity.x, -maxSloshing);
        }

        if (velocity.z > 0)
        {
            velocity.z = Mathf.Min(velocity.z, maxSloshing);
        }
        else
        {
            velocity.z = Mathf.Max(velocity.z, -maxSloshing);
        }

        liquidRenderer.material.SetFloat("_WaveXAmount", velocity.x * sloshingIntensity);
        liquidRenderer.material.SetFloat("_WaveZAmount", velocity.z * sloshingIntensity);
        liquidRenderer.material.SetFloat("_WaveHight", (velocity.x + velocity.z) * 0.5f * sloshingHightIntensity);


        lastPos = transform.position;
    }
}
