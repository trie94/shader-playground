// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        _Color ("Main Color", Color) = (1, 0, 0, 1)
        _Specular ("Specular Color", Color) = (1, 0, 0, 1)
        _AmbientColor ("Ambient Color", Color) = (1, 0, 0, 1)
        _NoiseFreq ("Noise Frequency", Range(0.0, 100.0)) = 2.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 0.3)) = 0.1
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

            float offsetHeight(float x, float y)
            {
                float3 worldPos = float3(x, y, 0);
                // vert.z = min(vert.z, snoise(vert * _NoiseFreq) * _NoiseIntensity + _HeightOffset);
                worldPos.y += surface3(worldPos * _NoiseFreq) * _NoiseIntensity + _HeightOffset;
                return worldPos.y;
            }

            float offsetHeight(float3 worldPos)
            {
                // vert.z = min(vert.z, snoise(float3(vert.x, vert.y, 0) * _NoiseFreq) * _NoiseIntensity + _HeightOffset);
                worldPos.y += surface3(worldPos * _NoiseFreq) * _NoiseIntensity + _HeightOffset;
                return worldPos.y;
            }

            float3 getNormal( float3 p )
            {
                float eps = 1e-4;
                return normalize( float3( offsetHeight(p.x-eps,p.y) - offsetHeight(p.x+eps,p.y), 2.0f*eps, offsetHeight(p.x,p.y-eps) - offsetHeight(p.x,p.y+eps) ) );
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.localPos = v.vertex.xyz;
                float4 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                worldPos.y = offsetHeight(worldPos.xyz);
                o.worldPos = worldPos;
                o.vertex = UnityWorldToClipPos(worldPos);
                o.uv = v.uv;
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = getNormal(i.localPos);
                float3 worldNormal = UnityObjectToWorldNormal(normal);
                if (abs(i.worldNormal.y) < 1e-4)
                {
                    worldNormal = i.worldNormal;
                }
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = saturate(dot(worldNormal, lightDir));
                fixed4 color;

                float3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 worldHalf = normalize(worldView + lightDir);

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * NdotL;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

                // color.rgb = _Color.rgb * _LightColor0.rgb * NdotL + _AmbientColor * _AmbientColor.a;
                // color.rgb = _Color.rgb * _LightColor0.rgb * NdotL;
                color.rgb = diffuse + _AmbientColor * _AmbientColor.a;
                color.a = _Color.a * 0.5;

                // return fixed4(worldNormal * 0.5 + 0.5, 1.0);
                return color;
            }
            ENDCG
        }
    }
}
