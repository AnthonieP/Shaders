Shader "Custom/FlippedGalaxy"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TexScale ("Texture Scale", float) = 1
		_RimEffect("Rim Effect", Range(0, 1)) = .5
		_RimCol("Rim Color", color) = (1,1,1,1)
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
			float4 _MainTex_ST;
			float _TexScale;



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
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				float posX = (i.posWorld.x * i.vertex.x);
				float posY = (i.posWorld.y * i.vertex.y);
				fixed roundedXPos = round(posX / _TexScale - 0.5);
				fixed roundedYPos = round(posY / _TexScale - 0.5);
				fixed2 uvCoords = fixed2(posX / _TexScale - roundedXPos, posY / _TexScale - roundedYPos);
                fixed4 col = tex2D(_MainTex, uvCoords);
                //fixed4 col = tex2D(_MainTex, i.uv);



                return col;
            }
            ENDCG
        }

		
    }
}
