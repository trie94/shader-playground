Shader "Unlit/iceCat"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        _BumpRamp ("Ramp Texture", 2D) = "white" {}
        [HDR]
        _RimColor ("Rim Color", Color) = (1, 0, 0, 1)
        _RimPower ("Rim Power", Range(0.1, 5.0)) = 1.0
        _FaceColor ("Face Color", Color) = (1, 1, 1, 1)
        _NoiseFreq ("Noise Frequency", Range(0.0, 20.0)) = 2.0
        _NoiseIntensity ("Noise Intensity", Range(0.0, 1.0)) = 0.5
        _BumpTex ("Bump Texture", 2D) = "white" {}
        _DistortStrength ("Distort Strength", Range(0.0, 3.0)) = 1.0
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

        GrabPass
        {
            "_BackgroundTexture"
        }

        // Background distortion
        Pass
        {
            Tags { "Queue" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Properties
            sampler2D _BackgroundTexture;
            sampler2D _BumpTex;
            float     _DistortStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 grabPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // screen space
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.uv = v.uv;

                // distort based on bump map
                float3 bump = tex2Dlod(_BumpTex, o.pos).rgb;
                // o.grabPos.x += bump.x * _DistortStrength;
                // o.grabPos.y += bump.y * _DistortStrength;
                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                fixed4 col = tex2Dproj(_BackgroundTexture, i.grabPos);
                return col;
            }
            ENDCG
        }

        // main
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
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
                float4 localPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            sampler2D _MainTex;
            sampler2D _BumpRamp;
            fixed4 _RimColor;
            fixed _RimPower;
            fixed4 _FaceColor;
            float _NoiseFreq;
            float _NoiseIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.localPos = v.vertex;
                o.uv = v.uv;
                o.normal = v.normal;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(ObjSpaceViewDir(i.localPos));
                half rim = saturate(1.0 - dot(normalize(i.normal), viewDir));
                rim = pow(rim, _RimPower);
                rim = step(0.5, rim);
                fixed4 rimColor = _RimColor;
                rimColor.a *= saturate(rim + 0.2);

                float attenuation = SHADOW_ATTENUATION(i);
                float3 lightDir;
                if (0.0 == _WorldSpaceLightPos0.w) // directional light?
                {
                    attenuation = 1.0; // no attenuation
                    lightDir = normalize(_WorldSpaceLightPos0.xyz);
                } 
                else // point or spot light
                {
                    float4 lightPosition = float4(unity_4LightPosX0[0], 
                    unity_4LightPosY0[0], 
                    unity_4LightPosZ0[0], 1.0);

                    float3 vertexToLightSource = lightPosition.xyz - i.worldPos.xyz;
                    float distance = length(vertexToLightSource);
                    attenuation = 1.0 / distance; // linear attenuation 
                    lightDir = normalize(vertexToLightSource);
                }

                float3 bump = normalize(snoise(i.localPos.xyz * _NoiseFreq).xxx * _NoiseIntensity + i.worldNormal.xyz);
                // float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float ramp = saturate(dot(bump, lightDir));
                float4 lighting = float4(tex2D(_BumpRamp, float2(ramp, 0.5)).rgb, 1.0);

                fixed4 face = tex2D(_MainTex, i.uv) * _FaceColor;
                fixed4 col;
                col.rgb = rimColor.rgb + face.rgb * (1-rimColor.a);
                col.a = max(face.a, rimColor.a);

                // return col * lighting * attenuation;
                return col * lighting;
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
