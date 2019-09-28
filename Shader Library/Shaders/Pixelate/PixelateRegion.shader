Shader "Unlit/PixelateRegion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 0, 0, 1)
        _CellSize ("Cell Size", Range(0.001, 0.5)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

		GrabPass
        {
            "_BackgroundTexture"
        }

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
                float4 grabPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _BackgroundTexture;
            fixed4 _Color;
            float _CellSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 steppedUV = i.grabPos.xy/i.grabPos.w;
                steppedUV /= _CellSize;
                steppedUV = round(steppedUV);
                steppedUV *= _CellSize;

                fixed4 col = tex2D(_BackgroundTexture, steppedUV);
                // fixed4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}
