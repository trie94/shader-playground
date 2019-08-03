// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/ground2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 0, 0, 1)
        // _Specular ("Specular Color", Color) = (1, 0, 0, 1)
        _AmbientColor ("Ambient Color", Color) = (1, 0, 0, 1)
        _NoiseFreq ("Noise Frequency", Range(0.0, 1.0)) = 1.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 10.0)) = 0.1
        _HeightOffset ("Height Offset", Range(-3.0, 0.5)) = 0.5
        _Metallic ("Metallic", Range(0.0, 3.0)) = 0.5
        _Glossiness ("Glossiness", Range(0.0, 3.0)) = 0.5
        _NoiseSeed ("Noise Seed", Range(0.0, 10.0)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
        #pragma target 3.0
        #include "noise.cginc"

        sampler2D _MainTex;
        float _NoiseFreq;
        float _NoiseIntensity;
        float _HeightOffset;
        fixed4 _Color;
        fixed4 _AmbientColor;
        fixed _Glossiness;
        fixed _Metallic;
        float4x4 _World2Camera;
        float _NoiseSeed;

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
            return snoise(p * _NoiseFreq) * _NoiseIntensity + _HeightOffset;
        }

        float3 getNormal( float3 p )
        {
            float eps = 1e-4;
            return normalize( float3( offsetHeight(float3(p.x-eps, p.y, p.z)) - offsetHeight(float3(p.x+eps, p.y, p.z)), offsetHeight(float3(p.x, p.y-eps, p.z)) - offsetHeight(float3(p.x, p.y+eps, p.z)), 2.0*eps));
            // float eps = 1e-4;
            // float2 h = float2(eps, 0);
            // return normalize(float3(offsetHeight(p-h.xyy) - offsetHeight(p+h.xyy),
            // 2.0*h.x, offsetHeight(p-h.yyx) - offsetHeight(p+h.yyx)));
        }

        void vert (inout appdata_full v, out Input o)
        {
            float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
            worldPos.y = min(worldPos.y, offsetHeight(worldPos));
            v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.wNormal = UnityObjectToWorldNormal(v.normal);
            // float3 worldNormal = getNormal(worldPos);
            // if (abs(o.wNormal.x) > 1e-8)
            // {
            //     worldNormal.x = 0;
            // }
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 worldNormal = getNormal(IN.worldPos);
            if (abs(IN.wNormal.y) < 1)
            {
                worldNormal = IN.wNormal;
                worldNormal.y = 0;
                worldNormal = normalize(worldNormal);
                // o.Emission = fixed3(1,0,0);
            }

            // fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = _Color.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            // o.Emission = worldNormal.xyz;
            o.Alpha = _Color.a;
            o.Normal = worldNormal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
