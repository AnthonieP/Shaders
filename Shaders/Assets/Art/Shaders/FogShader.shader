Shader "Custom/Fog"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		[HDR] _MainCol("Color", Color) = (1,1,1,1)
		_FogTex("Fog Height Texture", 2D) = "white" {}
		_FoxTexSpeedX("Fog Move Speed X", float) = 0
		_FoxTexSpeedZ("Fog Move Speed Z", float) = 0
		_FogTexEffect("Fog Height Effect", Range(0, 1)) = 0
		_FogState("Fog State", Range(0, 1)) = 0
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
			LOD 100

			Pass
			{
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

			//Variables
			sampler2D _MainTex;
			sampler2D _FogTex;
			float4 _MainTex_ST;
			half4 _MainCol;
			half _FogState;
			half _FogTexEffect;
			half _FoxTexSpeedX;
			half _FoxTexSpeedZ;
			sampler2D _CameraDepthTexture;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldViewDir : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float eyeZ : TEXCOORD3;
				float2 uv : TEXCOORD4;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeZ);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 fogHeight = tex2D(_FogTex, i.uv + float2(_Time.x * _FoxTexSpeedX, _Time.x * _FoxTexSpeedZ));

				//Depth calc
				float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				float intersect = ((screenZ - i.eyeZ)) * _FogState;
				intersect -= (fogHeight.x * _FogTexEffect);

				float4 finalCol = col * _MainCol;
				finalCol.a = intersect;


				if (intersect > _MainCol.a) {
					finalCol.a = _MainCol.a;
				}
				else if (intersect < 0) {

					finalCol.a = 0;
				}

				return finalCol;
			}
			ENDCG
		}
		}
}