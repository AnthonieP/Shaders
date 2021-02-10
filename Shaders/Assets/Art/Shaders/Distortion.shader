Shader "Custom/Distortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainCol ("Color", color) = (1,1,1,1)
    }
    SubShader
    {

        Pass
        {
			Tags { "RenderType"="Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _MainCol;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			fixed4 frag(v2f i) : COLOR
			{
				fixed2 tempUV = ComputeGrabScreenPos(i.vertex);
				tempUV *= 0;

                fixed4 col = tex2D(_MainTex, tempUV);

				
				fixed4 finalCol = col * _MainCol;
                return finalCol;
            }
            ENDCG
        }
    }
}
