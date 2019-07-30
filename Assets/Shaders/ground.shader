// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/ground"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        _Color ("Main Color", Color) = (1, 0, 0, 1)
        // _Specular ("Specular Color", Color) = (1, 0, 0, 1)
        _AmbientColor ("Ambient Color", Color) = (1, 0, 0, 1)
        _NoiseFreq ("Noise Frequency", Range(0.0, 10.0)) = 2.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 1.0)) = 0.1
        _HeightOffset ("Height Offset", Range(-1.0, 0.5)) = 0.5
        _Shininess ("Shininess", Range(0.0, 3.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "noise.cginc"

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
                float3 worldNormal : TEXCOORD2;
                float3 localPos : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float _NoiseFreq;
            float _NoiseIntensity;
            float _HeightOffset;
            float _Shininess;
            fixed4 _Color;
            fixed4 _AmbientColor;
            fixed4 _Specular;

            float surface3 (float3 coord)
            {
                float n = 0.0;
                n += 1.0 * abs(snoise(coord));
                n += 0.5 * abs(snoise(coord * 2.0));
                n += 0.25 * abs(snoise(coord * 4.0));
                n += 0.125 * abs(snoise(coord * 8.0));

                return n * 10;
            }

            float offsetHeight(float3 worldPos)
            {
                worldPos.y = snoise(worldPos * _NoiseFreq) * _NoiseIntensity + _HeightOffset;
                // worldPos.y += surface3(worldPos * _NoiseFreq) * _NoiseIntensity + _HeightOffset;
                return worldPos.y;
            }

            float3 getNormal( float3 p )
            {
                float eps = 1e-4;
                return normalize( float3( offsetHeight(float3(p.x-eps, p.y, p.z)) - offsetHeight(float3(p.x+eps, p.y, p.z)), 2.0*eps, offsetHeight(float3(p.x,p.y, p.z-eps)) - offsetHeight(float3(p.x, p.y, p.z+eps))));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.localPos = v.vertex.xyz;
                float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
                worldPos.y = min(worldPos.y, offsetHeight(worldPos.xyz));
                o.worldPos = worldPos;
                o.vertex = UnityWorldToClipPos(worldPos);
                o.uv = v.uv;
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldNormal = getNormal(i.worldPos);
                if (abs(i.worldNormal.y) < 1e-4)
                {
                    worldNormal = i.worldNormal;
                }

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = saturate(dot(worldNormal, lightDir) + 0.25);
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * NdotL;

                // float3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // float3 worldHalf = normalize(worldView + lightDir);
                // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

                fixed4 color;
                color.rgb = _Color.rgb * _LightColor0.rgb * NdotL + _AmbientColor * _AmbientColor.a;
                color.a = _Color.a;

                // return fixed4(worldNormal * 0.5 + 0.5, 1.0);
                return color;
            }
            ENDCG
        }
    }
}
