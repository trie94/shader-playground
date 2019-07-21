Shader "Unlit/rim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        [HDR]
        _RimColor ("Rim Color", Color) = (1, 0, 0, 1)
        _RimPower ("Rim Power", Range(0.1, 5.0)) = 1.0
        _FaceColor ("Face Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            ZWrite On
            ColorMask 0
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
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float4 localPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _RimColor;
            fixed _RimPower;
            fixed4 _FaceColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(ObjSpaceViewDir(i.localPos));
                half rim = saturate(1.0 - dot(normalize(i.normal), viewDir));
                rim = pow(rim, _RimPower);
                fixed4 face = tex2D(_MainTex, i.uv) * _FaceColor;

                fixed4 rimColor = _RimColor;
                rimColor.a *= rim;

                fixed4 col;
                col.rgb = rimColor.rgb + face.rgb * (1-rimColor.a);
                col.a = max(face.a, rimColor.a);
                return col;
            }
            ENDCG
        }
    }
}
