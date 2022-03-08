Shader "Custom/Ripple"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainCol("Color", Color) = (1,1,1,1)
		_Shine("Shine", float) = 1
		_ShineCol("Shine Color", Color) = (1,1,1,1)
		_RimPow("Rim", float) = 1
		_RimCol("Rim Color", Color) = (1,1,1,1)
		_RippleFrequency("Ripple Frequency", float) = 0
		_RippleSpeed("Ripple Speed", float) = 0
		_RippleHeight("Ripple Height", float) = 1
		_RippleFalloff("Ripple Falloff", float) = 1
		_RippleFalloffMaxMultiplier("Ripple Falloff Max Multiplier", float) = 1
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
				fixed4 _MainCol;
				half _Shine;
				fixed4 _ShineCol;
				half _RimPow;
				fixed4 _RimCol;
				int _RippleOriginCount;
				float3 _RippleOrigin[1000];
				half _RippleFrequency;
				half _RippleSpeed;
				half _RippleHeight;
				half _RippleFalloff;
				half _RippleFalloffMaxMultiplier;



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
					float3 worldPos = unity_ObjectToWorld._m03_m13_m23;

					

					for (int i = 0; i < _RippleOriginCount; i++)
					{
						//Do Ripple
						float tempXVert = v.vertex.x;
						float tempZVert = v.vertex.z;
						if (tempXVert < 0) {
							tempXVert *= 1;
						}
						if (tempZVert < 0) {
							tempZVert *= 1;
						}
						float3 origin = _RippleOrigin[i];

						float vertexDis = distance(float3(origin.x, 0, origin.z), float3(tempXVert, 0, tempZVert));
						float fallOff = _RippleFalloff / vertexDis;
						fallOff = min(_RippleFalloffMaxMultiplier, fallOff);
						fallOff = max(fallOff, 0);

						v.vertex.y += sin((vertexDis)*_RippleFrequency + (-_Time[1] * _RippleSpeed)) * _RippleHeight * fallOff;
					}


					


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
					float shadowAtten = LIGHT_ATTENUATION(i);
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
					float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shine) * _ShineCol;
					float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
					float3 rimLighting = atten * _LightColor0.xyz * _RimCol * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPow);

					float3 lightFinal = rimLighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
					col = half4(lightFinal.xyz, 1);



					return tex * col * _MainCol * shadowAtten;
				}
				ENDCG
			}

			/*
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
					float shadowAtten = LIGHT_ATTENUATION(i);
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
					float3 specularReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection)) * pow(saturate(dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shine) * _ShineCol;
					float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
					float3 rimLighting = atten * _LightColor0.xyz * _RimCol * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPow);

					float3 lightFinal = rimLighting + diffuseReflection + specularReflection;
					col = half4(lightFinal.xyz, 1);

					fixed4 finalCol = tex * col * _MainCol * shadowAtten;
					return finalCol;
				}
				ENDCG
			}
			*/

			
			//Shadow
			Pass
			{
				Name "ShadowCaster"
				Tags { "LightMode" = "ShadowCaster"}
				Blend SrcAlpha OneMinusSrcAlpha

				ZWrite On ZTest Less Cull Off

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_shadowcaster
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				int _RippleOriginCount;
				float3 _RippleOrigin[1000];
				half _RippleFrequency;
				half _RippleSpeed;
				half _RippleHeight;
				half _RippleFalloff;
				half _RippleFalloffMaxMultiplier;

				struct v2f
				{
					V2F_SHADOW_CASTER;
					float2 uv : TEXCOORD1;
				};


				v2f vert(appdata_full v)
				{
					v2f o;

					float3 worldPos = unity_ObjectToWorld._m03_m13_m23;

					

					for (int i = 0; i < _RippleOriginCount; i++)
					{
						//Do Ripple
						float tempXVert = v.vertex.x;
						float tempZVert = v.vertex.z;
						if (tempXVert < 0) {
							tempXVert *= 1;
						}
						if (tempZVert < 0) {
							tempZVert *= 1;
						}
						float3 origin = _RippleOrigin[i];

						float vertexDis = distance(float3(origin.x, 0, origin.z), float3(tempXVert, 0, tempZVert));
						float fallOff = _RippleFalloff / vertexDis;
						fallOff = min(_RippleFalloffMaxMultiplier, fallOff);
						fallOff = max(fallOff, 0);

						v.vertex.y += sin((vertexDis)*_RippleFrequency + (-_Time[1] * _RippleSpeed)) * _RippleHeight * fallOff;
					}



					o.uv = v.texcoord;
					TRANSFER_SHADOW_CASTER(o)

				return o;
				}

				float4 frag(v2f i) : COLOR
				{
					fixed4 c = tex2D(_MainTex, i.uv);


					SHADOW_CASTER_FRAGMENT(i)
				}
				ENDCG
			}



		}

}
