Shader "Custom/seaPlant"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Color2 ("Color2", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NoiseFreq ("Noise Frequency", Range(0.0, 1.0)) = 1.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 10.0)) = 0.1
        _Speed ("Speed", Range(1.0, 20.0)) = 0.1
        _SwayMax ("Sway Max", Range(0.0, 10.0)) = 0.1
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
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _Color2;
        float _NoiseFreq;
        float _NoiseIntensity;
        float _Speed;
        float _SwayMax;

        struct Input
        {
            float2 uv_MainTex;
            // float3 worldPos;
            float3 localPos;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v, out Input o)
        {
            float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
            float x = sin(worldPos.x + (_Time.x * _Speed)) * v.vertex.y;// x axis movements
            float z = sin(worldPos.z + (_Time.x * _Speed)) * v.vertex.y;// z axis movements
            v.vertex.x += step(0, v.vertex.y) * x * _SwayMax;
            v.vertex.z += step(0, v.vertex.y) * z * _SwayMax;
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.localPos = v.vertex.xyz;

            // v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
            // o.worldPos = worldPos;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 c = lerp(_Color2, _Color, IN.localPos.y);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
