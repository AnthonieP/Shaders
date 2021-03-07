Shader "Custom/Water"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainCol("Color", Color) = (1,1,1,1)
		_Shine("Shine", float) = 1
		_ShineCol("Shine Color", Color) = (1,1,1,1)
		_RimPow("Rim", float) = 1
		_RimCol("Rim Color", Color) = (1,1,1,1)
		_SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Glossiness("Glossiness", float) = 10

		//Water
		_WaveSpeedX("Wave Speed X", float) = 0
		_WaveSpeedZ("Wave Speed Z", float) = 0
		_WaveHeight("Wave Height", float) = 0
		_DepthTex("Depth Texture", 2D) = "white" {}
		_DepthScrollSpeedX("Depth Texture Scroll Speed X", float) = 0
		_DepthScrollSpeedZ("Depth Texture Scroll Speed Z", float) = 0
		_DepthScale("Depth Texture Scale", float) = 1
		_IntersectCol("Intersect Color", Color) = (1,1,1,1)
		_IntersectAmount("Intersect Amount", float) = 1
	}
		SubShader
		{
			Tags
			{
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
			}
			//LightBase
			Pass
			{
				Tags {"LightMode" = "ForwardBase" "Queue" = "Transparrent"}
				Blend SrcAlpha OneMinusSrcAlpha
				ZWrite Off
				Cull Off
				CGPROGRAM
				#pragma target 3.0
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"
				#include "Lighting.cginc"


				sampler2D _MainTex;
				sampler2D _DepthTex;
				sampler2D _CameraDepthTexture;
				float4 _MainTex_ST;
				fixed4 _MainCol;
				half _Shine;
				fixed4 _ShineCol;
				half _RimPow;
				fixed4 _RimCol;
				half _Glossiness;
				fixed4 _SpecularColor;
				half _WaveSpeedX;
				half _WaveSpeedZ;
				half _WaveHeight;
				half _DepthScrollSpeedX;
				half _DepthScrollSpeedZ;
				half _DepthScale;
				fixed3 _IntersectCol;
				half _IntersectAmound;



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
					float2 screenuv : TEXCOORD3;
					float depth : DEPTH;
					float3 normal : NORMAL;
					LIGHTING_COORDS(4, 5)

				};


				v2f vert(appdata v)
				{
					v2f o;

					float3 worldPos = unity_ObjectToWorld._m03_m13_m23;
					v.vertex.y += sin(((v.vertex.x + worldPos.x) * _WaveSpeedX + _Time[1]) + ((v.vertex.z + worldPos.z) * _WaveSpeedZ + _Time[1])) * _WaveHeight;

					float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
					half3 worldNormal = UnityObjectToWorldNormal(v.normal);

					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.normal = UnityObjectToWorldNormal(v.normal);
					o.worldNormal = normalDirection;
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.screenuv = ((o.pos.xy / o.pos.w) + 1) / 2;
					o.screenuv.y = 1 - o.screenuv.y;
					o.depth = -UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w;
					TRANSFER_VERTEX_TO_FRAGMENT(o)




					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 tex = tex2D(_MainTex, i.uv);
					float3 worldPos = unity_ObjectToWorld._m03_m13_m23;
					fixed2 roundedDepthScroll = fixed2(round(((i.uv.x + worldPos.x) * _DepthScale + _Time[1] * _DepthScrollSpeedX) - .5), round(((i.uv.y + worldPos.z) * _DepthScale + _Time[1] * _DepthScrollSpeedZ) - .5));
					fixed2 depthScroll = fixed2(((i.uv.x + worldPos.x) * _DepthScale + _Time[1] * _DepthScrollSpeedX) - roundedDepthScroll.x, ((i.uv.y + worldPos.z) * _DepthScale + _Time[1] * _DepthScrollSpeedZ) - roundedDepthScroll.y);
					fixed4 depthTex = tex2D(_DepthTex, depthScroll);
					i.worldNormal.y *= ((depthTex.x + 1) * .5);
					float3 lightDirection;
					float atten;
					float shadowAtten = LIGHT_ATTENUATION(i);
					float3 normalDirection = i.worldNormal;
					//float3 viewDirection = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
					float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0))).xyz;
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

					float3 reflectionDirection = normalize(_WorldSpaceCameraPos.xyz + (i.pos.xyz + mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0))).xyz);

					fixed4 finalCol = tex * col * _MainCol * shadowAtten;
					//finalCol = float4(reflectionDirection.x, reflectionDirection.x, reflectionDirection.x, 1);
					//finalCol = shadowAtten;

					float screenDepth = Linear01Depth(tex2D(_CameraDepthTexture, i.screenuv));
					float diff = screenDepth - i.depth;
					float intersect = 0;

					if (diff > 0) 
						intersect = 1 - smoothstep(0, _ProjectionParams.w * _IntersectAmound, diff);

					fixed4 glowColor = fixed4(lerp(_MainCol.rgb, _IntersectCol, pow(intersect, 4)), 1);
					finalCol = _MainCol * _MainCol.a + glowColor;
					finalCol.a = _MainCol.a;
					return finalCol;
				}
				ENDCG
			}

			//Light Add
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
				float _WaveSpeedX;
				float _WaveSpeedZ;
				float _WaveHeight;


				struct v2f
				{
					V2F_SHADOW_CASTER;
					float2 uv : TEXCOORD1;
				};


				v2f vert(appdata_full v)
				{
					v2f o;

					float3 worldPos = unity_ObjectToWorld._m03_m13_m23;
					v.vertex.y += sin(((v.vertex.x + worldPos.x) * _WaveSpeedX + _Time[1]) + ((v.vertex.z + worldPos.z) * _WaveSpeedZ + _Time[1])) * _WaveHeight;

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
		Fallback "diffuse"
}
