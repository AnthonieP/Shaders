Shader "Custom/Liquid"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainCol ("Color", color) = (1,1,1,1)
		_LiquidHight ("Liquid Hight", float) = 1
        _FoamCol ("Foam Color", color) = (1,1,1,1)
        _TopCol ("Top Foam Color", color) = (1,1,1,1)
		_FoamHight ("Foam Hight", float) = 1
		_WaveHight ("Wave Hight", float) = 1
		_WaveWidth ("Wave Width", float) = 1
		_WaveSpeed ("Wave Speed", float) = 1
		_WaveXAmount ("Wave X Amount", float) = 1
		_WaveZAmount ("Wave Z Amount", float) = 1
		_RimEffect("Rim Effect", Range(0, 1)) = .5
		_RimCol("Rim Color", color) = (1,1,1,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _MainCol;
			fixed4 _FoamCol;
			float _LiquidHight;
			float _FoamHight;
			float _WaveHight;
			float _WaveWidth;
			float _WaveSpeed;
			float _WaveXAmount;
			float _WaveZAmount;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				half3 posWorld : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 liquidCol = _MainCol;
				float4 objectOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));

				if (i.posWorld.y > objectOrigin.y + _LiquidHight + (sin(_Time[1] * _WaveSpeed + ((i.posWorld.x * _WaveXAmount) + (i.posWorld.z * _WaveZAmount)) * _WaveWidth) * _WaveHight))
				{
					discard;
				}
				if (i.posWorld.y > objectOrigin.y + _LiquidHight + (sin(_Time[1] * _WaveSpeed + ((i.posWorld.x * _WaveXAmount) + (i.posWorld.z * _WaveZAmount)) * _WaveWidth) * _WaveHight) - _FoamHight)
				{
					liquidCol = _FoamCol;
				}

				fixed4 finalCol = col * liquidCol;
                return finalCol;
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
			float _LiquidHight;
			float _FoamHight;
			float _WaveHight;
			float _WaveWidth;
			float _WaveSpeed;
			float _WaveXAmount;
			float _WaveZAmount;

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
				float4 objectOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));

				if (i.posWorld.y > objectOrigin.y + _LiquidHight + (sin(_Time[1] * _WaveSpeed + ((i.posWorld.x * _WaveXAmount) + (i.posWorld.z * _WaveZAmount)) * _WaveWidth) * _WaveHight))
				{
					discard;
				}

				return _RimCol * _RimCol.a * val * val * t;
			}

			ENDCG
		}

		Pass
		{
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _TopCol;
			float _LiquidHight;
			float _WaveHight;
			float _WaveWidth;
			float _WaveSpeed;
			float _WaveXAmount;
			float _WaveZAmount;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				half3 posWorld : TEXCOORD1;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float4 objectOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
				if (i.posWorld.y > objectOrigin.y + _LiquidHight + (sin(_Time[1] * _WaveSpeed + ((i.posWorld.x * _WaveXAmount) + (i.posWorld.z * _WaveZAmount)) * _WaveWidth) * _WaveHight))
				{
					discard;
				}

				
				return _TopCol;
			}
			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On ZTest Less Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _LiquidHight;
			float _WaveHight;
			float _WaveWidth;
			float _WaveSpeed;
			float _WaveXAmount;
			float _WaveZAmount;

			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 uv : TEXCOORD0;
				half3 posWorld : TEXCOORD1;
			};


			v2f vert(appdata_full v)
			{
				v2f o;
				o.uv = v.texcoord;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_SHADOW_CASTER(o)

			return o;
			}

			float4 frag(v2f i) : COLOR
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				float4 objectOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
				if (i.posWorld.y > objectOrigin.y + _LiquidHight + (sin(_Time[1] * _WaveSpeed + ((i.posWorld.x * _WaveXAmount) + (i.posWorld.z * _WaveZAmount)) * _WaveWidth) * _WaveHight))
				{
					discard;
				}
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
    }
}
