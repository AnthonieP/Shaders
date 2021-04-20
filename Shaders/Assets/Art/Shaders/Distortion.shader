Shader "Custom/Distortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainCol ("Color", color) = (1,1,1,1)
    }
    SubShader
    {


		GrabPass
		{
			"_GrabTexture"
		}

        Pass
        {
			Tags { "RenderType"="Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
			sampler2D _GrabTexture;
            float4 _MainTex_ST;
			fixed4 _MainCol;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
				float3 normal : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeGrabScreenPos(o.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

			fixed4 frag(v2f i) : COLOR
			{
				/*float3 vNormalTs = UnpackScaleNormal( tex2D( _BumpMap, i.vTexCoord0.xy ), 1 );

					// Tangent space -> World space
					float3 vNormalWs = Vec3TsToWsNormalized( vNormalTs.xyz, i.vNormalWs.xyz, i.vTangentUWs.xyz, i.vTangentVWs.xyz );

					// World space -> View space
					float3 vNormalVs = normalize(mul((float3x3)UNITY_MATRIX_V, vNormalWs));

					// Calculate offset
					float2 offset = vNormalVs.xy * _Refraction;
					offset *= pow(length(vNormalVs.xy), _Power);

					// Scale to pixel size
					offset /= float2(_ScreenParams.x, _ScreenParams.y);

					// Scale with screen depth
					offset /=  i.vPos.z;

					// Scale with vertex alpha
					offset *= pow(i.vColor.a, _AlphaPower);

					// Sample grab texture
					float4 vDistortColor = tex2Dproj(_GrabTexture, i.vGrabPos + float4(offset, 0.0, 0.0));

					// Debug normals
					// return float4(vNormalVs * 0.5 + 0.5, 1);

					return vDistortColor;*/

				return fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}
