Shader "Custom/Checkpoint"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _MainCol ("Color", color) = (1,1,1,1)
		_FadeoffHeight ("Fadeoff height", float) = 1
		_FadeoffPow ("Fadeoff power", float) = 1
    }
    SubShader
    {
        LOD 100

        Pass
        {
			Tags {"Queue" = "Transparrent"}
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
			half4 _MainCol;
			half _FadeoffHeight;
			half _FadeoffPow;


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
				float3 worldPos = unity_ObjectToWorld._m03_m13_m23;
                fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 finalCol = _MainCol;
				finalCol.a = col.x;

				float objHeight = i.posWorld.y - worldPos.y;
				if (objHeight > _FadeoffHeight) {
					discard;
				}
				else if (objHeight > _FadeoffHeight - _FadeoffPow) {
					half fadeoffSur = _FadeoffHeight - _FadeoffPow;
					half fadeoffStart = objHeight - fadeoffSur;
					finalCol.a *= 1 - (objHeight - fadeoffSur) / _FadeoffHeight;
					if (finalCol.a < 0) {
						finalCol.a = 0;
					}
				}

                return finalCol;
            }
            ENDCG
        }
    }
}
