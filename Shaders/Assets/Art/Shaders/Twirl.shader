Shader "Custom/Twirl"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _MainCol ("Twirl Color", color) = (1,1,1,1)
		_TwirlAngle ("Twirl Angle", float) = 0
		_TwirlSpeed ("Twirl Speed", float) = 0
    }
    SubShader
    {

        Pass
        {
			Tags { "RenderType"="Transparrent" }
			LOD 100
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainCol;
			float _TwirlAngle;
			float _TwirlSpeed;

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

			fixed4 frag(v2f i) : SV_Target
			{
				float2 delta = i.uv - fixed2(.5,.5);
				float angle = _TwirlAngle * length(delta);
				float x = cos(angle) * delta.x - sin(angle) * delta.y;
				float y = sin(angle) * delta.x + cos(angle) * delta.y;
				float2 twirl = float2(x + .5 + (_Time[1] * _TwirlSpeed), y + .5 + (_Time[1] * _TwirlSpeed));

				fixed4 finalCol = _MainCol;
                fixed4 col = tex2D(_MainTex, float2(twirl.x, twirl.y));


				finalCol.a = col.x;
                return finalCol;
            }
            ENDCG
        }
    }
}
