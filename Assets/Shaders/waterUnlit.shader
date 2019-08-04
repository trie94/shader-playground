Shader "Unlit/waterUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorB ("Up Color", Color) = (1, 0, 0, 1)
        _ColorA ("Bottom Color", Color) = (1, 0, 0, 1)
        _NoiseFreq ("Noise Frequency", Range(0.0, 1.0)) = 1.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 3.0)) = 0.1
        _HeightOffset ("Height Offset", Range(0.0, 10.0)) = 2.0
        _NoiseSeed ("Noise Seed", Range(0.0, 10.0)) = 1.0
        _Speed ("Speed", Range(0.0, 5.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 localPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            fixed4 _ColorA;
            fixed4 _ColorB;
            float _NoiseFreq;
            float _NoiseIntensity;
            float _HeightOffset;
            float _NoiseSeed;
            float _Offset;
            float _Speed;

            float offsetHeight(float3 p)
            {
                p.y = _NoiseSeed;
                return snoise(p * _NoiseFreq + _Time.y * _Speed) * _NoiseIntensity + _HeightOffset;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
                worldPos.y = min(worldPos.y, offsetHeight(worldPos));
                v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex.xyz;
                o.worldPos = worldPos;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = lerp(_ColorA, _ColorB, i.localPos.y);
                col.a = min(_ColorA.a, _ColorB.a);
                return col;
            }
            ENDCG
        }
    }
}
