Shader "Custom/Galaxy"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TexScale ("Texture Scale", float) = 1
		_RimEffect("Rim Effect", Range(0, 1)) = .5
		_RimCol("Rim Color", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
			float _TexScale;



            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				half3 posWorld : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed roundedXPos = round(i.vertex.x / _TexScale - 0.5);
				fixed roundedYPos = round(i.vertex.y / _TexScale - 0.5);
				fixed2 uvCoords = fixed2(i.vertex.x / _TexScale - roundedXPos, i.vertex.y / _TexScale - roundedYPos);
                fixed4 col = tex2D(_MainTex, uvCoords);



                return col;
            }
            ENDCG
        }

		Pass {
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _RimCol;
			fixed _RimEffect;

			struct v2f {
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				half3 posWorld : TEXCOORD2;
			};


			v2f vert(appdata_full v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal.xyz));
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)));
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}


			fixed4 frag(v2f i) : COLOR {
				float t = tex2D(_MainTex, i.uv);
				float val = 1 - abs(dot(i.viewDir, i.normal)) * _RimEffect;

				return _RimCol * _RimCol.a * val * val;
			}

			ENDCG
		}
    }
}
