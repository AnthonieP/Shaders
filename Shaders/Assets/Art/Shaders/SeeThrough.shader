Shader "Custom/SeeThrough"
{
	Properties{
	 _MainTex("MainTex", 2D) = "white" {}
	 _MainCol("MainCol", Color) = (0,0,0,0)
	}

		SubShader{
			Tags {"Queue" = "Geometry+1" "RenderType" = "Opaque"}
			ZTest Less
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass {
				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#pragma fragmentoption ARB_precision_hint_fastest
					#include "UnityCG.cginc"

					struct appdata {
						float4 vertex : POSITION;
						float2 texcoord : TEXCOORD0;
					};

					struct v2f {
						float4 vertex : SV_POSITION;
						half2 texcoord : TEXCOORD0;
					};

					sampler2D _MainTex;
					fixed4 _MainCol;
					float4 _MainTex_ST;

					v2f vert(appdata v)
					{
						v2f o;
						o.vertex = UnityObjectToClipPos(v.vertex);
						o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
						return o;
					}

					fixed4 frag(v2f i) : SV_Target
					{
						fixed4 col = tex2D(_MainTex, i.texcoord);
						return col * _MainCol;
					}
				ENDCG
			}
	}
}
