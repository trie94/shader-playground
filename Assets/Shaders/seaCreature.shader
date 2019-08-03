Shader "Custom/seaCreature"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NoiseFreq ("Noise Frequency", Range(0.0, 1.0)) = 1.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 10.0)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade
        #pragma target 3.0
        #include "noise.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _NoiseFreq;
        float _NoiseIntensity;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v, out Input o)
        {
            float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
            worldPos.x += snoise(worldPos * _NoiseFreq) * _NoiseIntensity;
            worldPos.y -= snoise(worldPos * _NoiseFreq) * _NoiseIntensity;
            worldPos.z += snoise(worldPos * _NoiseFreq) * _NoiseIntensity;
            v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
            UNITY_INITIALIZE_OUTPUT(Input, o);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Emission = _Color.rgb * 0.75;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
