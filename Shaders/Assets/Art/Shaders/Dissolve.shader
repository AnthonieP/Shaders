Shader "Custom/Dissolve"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainCol("Color", Color) = (1,1,1,1)
		_Shine("Shine", float) = 1
		_ShineCol("Shine Color", Color) = (1,1,1,1)
		_RimPow("Rim", float) = 1
		_RimCol("Rim Color", Color) = (1,1,1,1)
		_DissTex("Dissolve Texture", 2D) = "white" {}
		[HDR] _DissCol("Dissolve Color", Color) = (1,1,1,1)
		_DissWidth("Dissolve Color Width", Range(0, 0.1)) = 0
		_DissState("Dissolve State", Range(-0.1, 1.1)) = 0
	}
		SubShader
		{

			Pass
			{
				Tags {"LightMode" = "ForwardBase" }

				Cull Off
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
				sampler2D _DissTex;
				fixed4 _DissCol;
				fixed _DissWidth;
				fixed _DissState;



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
					fixed4 dissTex = tex2D(_DissTex, i.uv);
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

					fixed4 finalCol = tex * col * _MainCol * shadowAtten;
					if (dissTex.x < _DissState + _DissWidth) 
					{
						finalCol = _DissCol;
					}
					if (dissTex.x < _DissState) 
					{
						discard;

					}


					return finalCol;
				}
				ENDCG
			}

			Pass
			{
				Tags {"LightMode" = "ForwardAdd"}
				ZWrite Off
				Cull Off
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
				sampler2D _DissTex;
				fixed4 _DissCol;
				fixed _DissWidth;
				fixed _DissState;



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
					fixed4 tex = tex2D(_MainTex, i.uv);
					fixed4 dissTex = tex2D(_DissTex, i.uv);
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

					fixed4 finalCol = col * shadowAtten;
					if (dissTex.x < _DissState + _DissWidth)
					{
						finalCol = _DissCol;
					}
					if (dissTex.x < _DissState)
					{
						discard;

					}


					return finalCol;
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
				sampler2D _DissTex;
				fixed _DissState;

				struct v2f
				{
					V2F_SHADOW_CASTER;
					float2 uv : TEXCOORD1;
				};


				v2f vert(appdata_full v)
				{
					v2f o;
					o.uv = v.texcoord;
					TRANSFER_SHADOW_CASTER(o)

				return o;
				}

				float4 frag(v2f i) : COLOR
				{
					fixed4 c = tex2D(_MainTex, i.uv);
					fixed4 dissTex = tex2D(_DissTex, i.uv);
					if (dissTex.x < _DissState)
					{
						discard;
					}
					SHADOW_CASTER_FRAGMENT(i)
				}
				ENDCG
			}



			


		}
		
}
