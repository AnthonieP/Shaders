// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Test"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0)
		_GlowColor("Glow Color", Color) = (1, 1, 1, 1)
		_FadeLength("Fade Length", Range(0, 2)) = 0.15
	}
		SubShader
	{
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 screenuv : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float depth : DEPTH;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				float3 worldPos = unity_ObjectToWorld._m03_m13_m23;
				v.vertex.y += sin(((v.vertex.x + worldPos.x) * 1 + _Time[1]) + ((v.vertex.z + worldPos.z) * 1 + _Time[1])) * .3;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.screenuv = ((o.vertex.xy / o.vertex.w) + 1) / 2;
				o.screenuv.y = 1 - o.screenuv.y;
				o.depth = -UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w;

				return o;
			}

			sampler2D _CameraDepthTexture;
			fixed4 _Color;
			fixed3 _GlowColor;
			float _FadeLength;

			fixed4 frag(v2f i) : SV_Target
			{
				float screenDepth = Linear01Depth(tex2D(_CameraDepthTexture, i.screenuv));
				float diff = screenDepth - i.depth;
				float intersect = 0;

				if (diff > 0)
					intersect = 1 - smoothstep(0, _ProjectionParams.w * _FadeLength, diff);

				fixed4 glowColor = fixed4(lerp(_Color.rgb, _GlowColor, pow(intersect, 4)), 1);

				fixed4 col = _Color * _Color.a + glowColor;
				col.a = _Color.a;
				return col;
			}
				ENDCG
	}
	}
}