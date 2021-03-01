Shader "Custom/Reflective"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainCol("Color", Color) = (1,1,1,1)
		_Shine("Shine", float) = 1
		_ShineCol("Shine Color", Color) = (1,1,1,1)
		_RimPow("Rim", float) = 1
		_RimCol("Rim Color", Color) = (1,1,1,1)

		//Reflective
		_ReflectiveTex("Reflective Texture", 2D) = "defaulttexture" {}
		_ReflectiveCol("Reflective Color", Color) = (1,1,1,1)
		_ReflectiveMinAngle("Reflective Angle Min", Vector) = (0,0,0,0)
		_ReflectiveMaxAngle("Reflective Angle Max", Vector) = (0,0,0,0)

		//UV Light
		_UVTexture("UV Texture", 2D) = "defaulttexture" {}
		[HDR] _UVColor("UV Color", Color) = (1,1,1,1)
		_UVLightColor("UV Light Color", Color) = (1,1,1,1)
	}
		SubShader
		{
			
			//Light Base
			Pass
			{
				Name "Light Base"
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

					float3 lightFinal = rimLighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
					col = half4(lightFinal.xyz, 1);



					return tex * col * _MainCol * shadowAtten;
				}
				ENDCG
			}

			//Light Add
			Pass
			{
				Name "LightAdd"
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

			//Reflection
			Pass
			{
				Name "Reflective"
				Tags { "Queue" = "Transparent" }
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
				sampler2D _ReflectiveTex;
				float4 _MainTex_ST;
				sampler2D _LightTex;
				fixed4 _MainCol;
				fixed4 _OutlineCol;
				half _Shine;
				fixed4 _ShineCol;
				half _RimPow;
				fixed4 _RimCol;
				fixed4 _ReflectiveMinAngle;
				fixed4 _ReflectiveMaxAngle;
				fixed4 _ReflectiveCol;



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
					float3 viewDir : TEXCOORD3;
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
					o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)));




					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 tex = tex2D(_MainTex, i.uv);
					fixed4 refTex = tex2D(_ReflectiveTex, i.uv);
					float3 normalDirection = i.worldNormal;
					float4 rot = mul(unity_ObjectToWorld, float4(i.pos.xyz, 0.0));
					fixed4 finalCol = fixed4(0,0,0,0);

					if (normalDirection.x > _ReflectiveMinAngle.x && normalDirection.y > _ReflectiveMinAngle.y && normalDirection.z > _ReflectiveMinAngle.z && 
						normalDirection.x < _ReflectiveMaxAngle.x && normalDirection.y < _ReflectiveMaxAngle.y && normalDirection.z < _ReflectiveMaxAngle.z && refTex.a > 0) 
					{
						finalCol = _ReflectiveCol;
						float middleX = (_ReflectiveMinAngle.x + _ReflectiveMaxAngle.x) * 0.5;
						float middleY = (_ReflectiveMinAngle.y + _ReflectiveMaxAngle.y) * 0.5;
						float middleZ = (_ReflectiveMinAngle.z + _ReflectiveMaxAngle.z) * 0.5;
						if (normalDirection.x < middleX) 
						{
							finalCol *= (normalDirection.x - _ReflectiveMinAngle.x);
						}
						else 
						{
							finalCol *= -(normalDirection.x - _ReflectiveMaxAngle.x);
						}
						if (normalDirection.y < middleY)
						{
							finalCol *= (normalDirection.y - _ReflectiveMinAngle.y);
						}
						else
						{
							finalCol *= -(normalDirection.y - _ReflectiveMaxAngle.y);
						}
						if (normalDirection.z < middleZ)
						{
							finalCol *= (normalDirection.z - _ReflectiveMinAngle.z);
						}
						else
						{
							finalCol *= -(normalDirection.z - _ReflectiveMaxAngle.z);
						}

					}

					return finalCol;
				}
				ENDCG
			}

			//UV Light
			Pass
			{
				Name "UV Light"
				Tags {"Queue" = "Transparent"}
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
				sampler2D _UVTexture;
				float4 _MainTex_ST;
				fixed4 _UVColor;
				fixed4 _UVLightColor;



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
					fixed4 tex = tex2D(_UVTexture, i.uv);

					fixed4 finalCol = fixed4(0,0,0,0);
					if (_LightColor0.r == _UVLightColor.r && _LightColor0.g == _UVLightColor.g && _LightColor0.b == _UVLightColor.b)
					{
						finalCol = tex * _UVColor;
					}

					return finalCol;
				}
				ENDCG
			}

			//Shadows
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
