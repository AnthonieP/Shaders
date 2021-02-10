﻿Shader "Custom/CellShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainCol("Color", Color) = (1,1,1,1)
		_LightTex("Light Gradient", 2D) = "white" {}
		_Shine("Shine", float) = 1
		_ShineCol("Shine Color", Color) = (1,1,1,1)
		_RimPow("Rim", float) = 1
		_RimCol("Shine Color", Color) = (1,1,1,1)
	}

	SubShader
	{

		Pass
		{
			Tags {"LightMode" = "ForwardBase" }
			LOD 100
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LightTex;
			fixed4 _MainCol;
			half _Shine;
			fixed4 _ShineCol;
			half _RimPow;
			fixed4 _RimCol;



			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				half3 posWorld : TEXCOORD1;
				half3 worldNormal : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
			};


			v2f vert(appdata v)
			{
				v2f o;
				float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalDirection;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//TRANSFER_VERTEX_TO_FRAGMENT(o)




				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 tex = tex2D(_MainTex, i.uv);
				float3 lightDirection;
				float atten;
				float3 normalDirection = i.worldNormal;
				float3 viewDirection = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
				float4 col = float4(0, 0, 0, 0);
				if (_WorldSpaceLightPos0.w == 0) {
					//DirectionalLight
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					atten = 1;
				}
				else {
					//PointLight
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float distance = length(fragmentToLightSource);
					atten = 1 / distance;
					lightDirection = normalize(fragmentToLightSource);
				}
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));

				float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
				col = half4(lightFinal.xyz, 1);

				col = tex2D(_LightTex, float2(0.99 - saturate(dot(normalDirection, lightDirection)) * 0.98,0));


				return tex * col * _MainCol;
			}
			ENDCG
		}

		Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LightTex;
			fixed4 _MainCol;
			fixed4 _OutlineCol;
			half _Shine;
			fixed4 _ShineCol;
			half _RimPow;
			fixed4 _RimCol;



			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				half3 posWorld : TEXCOORD1;
				half3 worldNormal : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
			};


			v2f vert(appdata v)
			{
				v2f o;
				float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalDirection;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				TRANSFER_VERTEX_TO_FRAGMENT(o)





				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 tex = tex2D(_MainTex, i.uv);
				float3 lightDirection;
				float atten;
				float3 normalDirection = i.worldNormal;
				float3 viewDirection = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
				float4 col = float4(0, 0, 0, 0);
				if (_WorldSpaceLightPos0.w == 0) {
					//DirectionalLight
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					atten = 1;
				}
				else {
					//PointLight
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float distance = length(fragmentToLightSource);
					atten = 1 / distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
				col = tex2D(_LightTex, float2(0.99 - saturate(dot(normalDirection, lightDirection)) * 0.98, 0));

				col = tex2D(_LightTex, float2(1 - diffuseReflection.x, .5));

				return tex * col * _MainCol * atten;
			}
			ENDCG
		}

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma target 2.0

			#pragma multi_compile_shadowcaster

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster

			#include "UnityStandardShadow.cginc"

			ENDCG
		}

			

	}

}