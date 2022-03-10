using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleObject : MonoBehaviour
{
    [Header("Ripple Values")]
    public float rippleFrequency;
    public float rippleHeightMul;
    public float rippleFalloff;
    public float stayRippleHeightMul;
    public float stayRippleFalloff;
    public float rippleUpdateTime;
    float rippleUpdateTimeTime;
    [Header("Components")]
    Rigidbody rigidbody;
    Vector3 lastFramePos;

    private void Start()
    {
        rigidbody = GetComponent<Rigidbody>();
        lastFramePos = transform.position;
    }

    private void Update()
    {
        rippleUpdateTimeTime -= Time.deltaTime;
        lastFramePos = transform.position;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.transform.tag == "RippleObj")
        {
            float yVelocity = rigidbody.velocity.y;
            if(yVelocity < 0)
            {
                yVelocity *= -1;
            }

            other.transform.GetComponent<RippleController>().AddRipple(transform.position, rippleFrequency, rippleHeightMul * yVelocity, rippleFalloff);
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if(rippleUpdateTimeTime < 0)
        {
            if(lastFramePos.x != transform.position.x || lastFramePos.z != transform.position.z)
            {
                rippleUpdateTimeTime = rippleUpdateTime;
                float curXZVel = Vector3.Distance(new Vector3(transform.position.x, 0, transform.position.z), new Vector3(lastFramePos.x, 0, lastFramePos.z));

                other.transform.GetComponent<RippleController>().AddRipple(transform.position, rippleFrequency, curXZVel * stayRippleHeightMul, stayRippleFalloff);
            }
        }
    }
}
