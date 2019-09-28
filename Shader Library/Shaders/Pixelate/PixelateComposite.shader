Shader "Unlit/PixelateComposite"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float2 uv2 : TEXCOORD1;
            };

			sampler2D _MainTex;
			sampler2D _PixelatedTexture;

			int _PixelDensity;
			float2 _AspectRatioMultiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.uv2 = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				float2 pixelScaling = _PixelDensity * _AspectRatioMultiplier;
				i.uv2 = round(i.uv2 * pixelScaling)/ pixelScaling;

				fixed4 pixelated = tex2D(_PixelatedTexture, i.uv2);
				col = max(0, col - pixelated);
				col = col * (1- pixelated.a) + pixelated * pixelated.a;
                return col;
            }
            ENDCG
        }
    }
}
