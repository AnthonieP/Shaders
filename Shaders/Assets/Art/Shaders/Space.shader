Shader "Custom/Space"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_StarTex("Star Texture", 2D) = "clear" {}
        _StarBrightness ("Star Brightness", float) = 1
        _TexScale ("Texture Scale", float) = 1
        _CamMoveEffect ("Camera move effect", float) = 1
    }
    SubShader
    {
        Pass
        {
			Tags {"Queue" = "Transparrent"}
			Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _StarTex;
			float4 _MainTex_ST;
			float _TexScale;
			float _CamMoveEffect;
			float _StarBrightness;



            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				float3 viewDir = i.viewDir.xyz;
				float3 vertex = i.vertex.xyz;
				
				float posX = vertex.z + (viewDir.x * _CamMoveEffect);
				float posY = vertex.x + (viewDir.y * _CamMoveEffect);
				fixed roundedXPos = round(posX / _TexScale - 0.5);
				fixed roundedYPos = round(posY / _TexScale - 0.5);
				fixed2 uvCoords = fixed2(posX / _TexScale - roundedXPos, posY / _TexScale - roundedYPos);
                fixed4 col = tex2D(_MainTex, uvCoords);
                fixed4 starCol = tex2D(_StarTex, uvCoords);
				half4 finalCol = col;
				if (starCol.a != 0) {
					starCol *= _StarBrightness;
					finalCol = starCol;
				}


                return finalCol;
            }
            ENDCG
        }

		
    }
}
