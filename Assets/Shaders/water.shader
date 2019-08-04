Shader "Custom/water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 0, 0, 1)
        _Color2 ("Color2", Color) = (1, 0, 0, 1)
        // _Specular ("Specular Color", Color) = (1, 0, 0, 1)
        _AmbientColor ("Ambient Color", Color) = (1, 0, 0, 1)
        _NoiseFreq ("Noise Frequency", Range(0.0, 1.0)) = 1.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 10.0)) = 0.1
        _HeightOffset ("Height Offset", Range(0.0, 10.0)) = 2.0
        _Metallic ("Metallic", Range(0.0, 3.0)) = 0.5
        _Glossiness ("Glossiness", Range(0.0, 3.0)) = 0.5
        _NoiseSeed ("Noise Seed", Range(0.0, 10.0)) = 1.0
        _Offset ("Offset", Range(0.0, 10.0)) = 1.0
        _Speed ("Speed", Range(0.0, 2.0)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow alpha:fade
        #pragma target 3.0
        #include "noise.cginc"

        sampler2D _MainTex;
        float _NoiseFreq;
        float _NoiseIntensity;
        float _HeightOffset;
        fixed4 _Color;
        fixed4 _Color2;
        fixed4 _AmbientColor;
        fixed _Glossiness;
        fixed _Metallic;
        float4x4 _World2Camera;
        float _NoiseSeed;
        float _Offset;
        float _Speed;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 wNormal;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        float surface3 (float3 coord)
        {
            float n = 0.0;
            n += 1.0 * abs(snoise(coord));
            n += 0.5 * abs(snoise(coord * 2.0));
            n += 0.25 * abs(snoise(coord * 4.0));
            n += 0.125 * abs(snoise(coord * 8.0));

            return n * 10;
        }

        float offsetHeight(float3 p)
        {
            p.y = _NoiseSeed;
            return snoise(p * _NoiseFreq + _Time.y * _Speed) * _NoiseIntensity + _HeightOffset;
        }

        float3 getNormal( float3 p )
        {
            float eps = 1e-4;
            return normalize( float3( offsetHeight(float3(p.x-eps, p.y, p.z)) - offsetHeight(float3(p.x+eps, p.y, p.z)), offsetHeight(float3(p.x, p.y-eps, p.z)) - offsetHeight(float3(p.x, p.y+eps, p.z)), 2.0*eps));
        }

        void vert (inout appdata_full v, out Input o)
        {
            float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
            worldPos.y = min(worldPos.y, offsetHeight(worldPos));
            v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.wNormal = UnityObjectToWorldNormal(v.normal);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 worldNormal = getNormal(IN.worldPos);
            if (abs(IN.wNormal.y) < 1e-4)
            {
                worldNormal = IN.wNormal;
                worldNormal.y = 0;
                worldNormal = normalize(worldNormal);
            }

            o.Albedo = lerp(_Color, _Color2, IN.worldPos.y);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = _Color.a;
            o.Normal = worldNormal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
