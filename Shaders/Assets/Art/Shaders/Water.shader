Shader "Custom/Water"
{
	Properties
	{
		_MainTex("MainTexture", 2D) = "white" {}
		_MainCol("MainColor", Color) = (1,1,1,1)
		_Shine("Shine", float) = 1
		_ShineCol("Shine Color", Color) = (1,1,1,1)
		_RimPow("Rim", float) = 1
		_RimCol("Shine Color", Color) = (1,1,1,1)
		_Width("Vert width", int) = 1
		_Height("Vert height", int) = 1
		_Scale("Perlin scale", float) = 1
		_Speed("wave Speed", float) = 1
		_XWaveIntesity("X Wave Intesity", float) = 1
		_ZWaveIntesity("Z Wave Intesity", float) = 1
		_WaveIntensity("Wave Height", float) = 1
	}
		SubShader
	{
		Pass
		{
			Tags {"LightMode"="ForwardBase" "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			LOD 200
			ZWrite On
			Cull Off
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"


			sampler2D _MainTex;
			fixed4 _MainCol;
			float _Shine;
			fixed4 _ShineCol;
			float _RimPow;
			fixed4 _RimCol;
			int _Width;
			int _Height;
			float _Scale;
			float _Speed;
			float _WaveIntensity;
			float _XWaveIntesity;
			float _ZWaveIntesity;


			fixed4 _LightColor0;


			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 

			struct vertexOutput {
				float4 pos : SV_POSITION;
				half3 posWorld : TEXCOORD0;
				half3 worldNormal : TEXCOORD1;
				LIGHTING_COORDS(2, 3)

			};

			vertexOutput vert(vertexInput v) {
				vertexOutput o;
				float value = sin((_Time[1] * _Speed) + (v.vertex.x * _XWaveIntesity) + (v.vertex.z * _ZWaveIntesity));
				v.vertex.y += value * _WaveIntensity;
				float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				



				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalDirection;
				//TRANSFER_VERTEX_TO_FRAGMENT(o)

				return o;
			}

			

			fixed4 frag(vertexOutput i) : COLOR
			{
				float3 lightDirection;
				float atten;
				float shadowAtten = LIGHT_ATTENUATION(i);
				float3 normalDirection = i.worldNormal;
				float3 viewDirection = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);
				float4 col = float4(0,0,0,0);
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

				
				return col * _MainCol * shadowAtten;
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
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _MainCol;
			float _Shine;
			fixed4 _ShineCol;
			float _RimPow;
			fixed4 _RimCol;
			int _Width;
			int _Height;
			float _Scale;
			float _Speed;
			float _WaveIntensity;
			float _XWaveIntesity;
			float _ZWaveIntesity;


			fixed4 _LightColor0;


			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				half3 posWorld : TEXCOORD0;
				half3 worldNormal : TEXCOORD1;

			};

			vertexOutput vert(vertexInput v) {
				vertexOutput o;
				float value = sin((_Time[1] * _Speed) + (v.vertex.x * _XWaveIntesity) + (v.vertex.z * _ZWaveIntesity));
				v.vertex.y += value * _WaveIntensity;
				float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalDirection;
				return o;
			}



			fixed4 frag(vertexOutput i) : COLOR
			{
				float3 lightDirection;
				float atten;
				float3 normalDirection = i.worldNormal;
				float3 viewDirection = normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz);

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
				float4 col;
				col = half4(lightFinal.xyz, 1);


				return col * _MainCol;
			}

			ENDCG
		}
    }
	Fallback "Transparent/VertexLit"
}
