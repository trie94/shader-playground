﻿Shader "Custom/anotherSeaPlant"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Color2 ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Frequency ("Frequency", Range(0.0, 10.0)) = 0.1
        _Amplitude ("Amplitude", Range(0.0, 10.0)) = 0.1
        _YOffset ("Height Offset", Range(0.0, 1.0)) = 0.1
        _Speed ("Speed", Range(0.0, 3.0)) = 1.0
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
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _Color2;
        float _Speed;
        float _SwayMax;
        float _Frequency;
        float _Amplitude;
        float _YOffset;

        struct Input
        {
            float2 uv_MainTex;
            float3 localPos;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v, out Input o)
        {
            float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
            float height = worldPos.y - _YOffset;
            float x = sin(worldPos.y * _Frequency + _Time.y * _Speed) * _Amplitude;
            v.vertex.x += x * saturate(height);
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.localPos = v.vertex.xyz;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = lerp(_Color2, _Color, IN.localPos.y);
            o.Albedo = c.rgb;
            // o.Metallic = _Metallic;
            // o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
