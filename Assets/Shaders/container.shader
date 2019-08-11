Shader "Unlit/container"
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
                float4 localPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _BumpRamp;
            fixed4 _RimColor;
            float _RimPower;
            fixed4 _FaceColor;
            float _NoiseFreq;
            float _NoiseIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.localPos = v.vertex;
                o.uv = v.uv;
                o.normal = v.normal;
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

                float3 bump = normalize(snoise(i.localPos.xyz * _NoiseFreq).xxx * _NoiseIntensity + i.worldNormal.xyz);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float ramp = saturate(dot(bump, lightDir));
                float4 lighting = float4(tex2D(_BumpRamp, float2(ramp, 0.5)).rgb, 1.0);

                fixed4 face = tex2D(_MainTex, i.uv) * _FaceColor;
                fixed4 col;
                col.rgb = rimColor.rgb + face.rgb * (1-rimColor.a);
                col.a = max(face.a, rimColor.a);

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
            #include "AutoLight.cginc"

            struct appdata
            {
	            float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            float4 vert (appdata v) : SV_POSITION
            {
                // float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // half rim = saturate(1.0 - dot(normalize(v.normal), lightDir));
                // rim = step(0.6, rim);
                float4 localPos = UnityClipSpaceShadowCasterPos(v.vertex.xyz, 0);
	            return UnityApplyLinearShadowBias(localPos);
            }

            float4 frag () : SV_TARGET
            {
                return 0;
            }
            ENDCG
        }
    }
}
