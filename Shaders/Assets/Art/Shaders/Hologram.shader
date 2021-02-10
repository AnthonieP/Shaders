
Shader "Custom/Hologram"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _HolTex ("Hologram Texture", 2D) = "white" {}
		[HDR] _HolCol("Hologram Color", Color) = (1,1,1,1)
		_HolTexScale("Hologram Scale", float) = 1
		_HolSpeed("Hologram Speed", float) = 1
		_RimPower("Rim Power", float) = 1
    }
    SubShader
    {
		Tags {"Queue" = "Geometry+1" "RenderType" = "Opaque"}
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _HolTex;
			fixed4 _HolCol;
			float _HolTexScale;
			float _HolSpeed;
			float _RimPower;

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal.xyz));
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				float roudedVertex = round(((i.vertex.y + (_Time[1] * _HolSpeed)) * _HolTexScale) - 0.5);
				fixed4 holTexCol = tex2D(_HolTex, fixed2(.5, (((i.vertex.y + (_Time[1] * _HolSpeed)) * _HolTexScale) - roudedVertex)));
				float val = 1 - abs(dot(i.viewDir, i.normal)) * _RimPower;


				col.a = holTexCol.x + val;


                return col * _HolCol;
            }
            ENDCG
        }
    }
}
