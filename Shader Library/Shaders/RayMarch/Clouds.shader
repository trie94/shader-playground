Shader "Hidden/Clouds"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "DistanceFunctions.cginc"
			#include "Noise.cginc"
			
			sampler2D _MainTex;
			uniform sampler2D _CameraDepthTexture;
			uniform fixed4 _LightColor1, _LightColor2;
			uniform fixed4 _CloudBaseColor1, _CloudBaseColor2;
			uniform half _LightIntensity;
			uniform float4x4 _CamFrustum;
			uniform float4x4 _CamToWorld;
			uniform float _MaxDistance;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 ray : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                half index = v.vertex.z;
				v.vertex.z = 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.ray = _CamFrustum[(int)index].xyz;
				o.ray /= abs(o.ray.z);
				o.ray = mul(_CamToWorld, float4(o.ray, 0));
                return o;
            }

			float map(float3 pos)
			{
				float noise = 0.50000*snoise(pos); pos = pos*2.02;
				noise += 0.25000*snoise(pos); pos = pos*2.03;
				noise += 0.12500*snoise(pos); pos = pos*2.01;
				noise += 0.06250*snoise(pos); pos = pos*2.02;
				noise += 0.03125*snoise(pos);
				return saturate(noise);
			}

			float4 integrate(float4 sum, float dif, float den, float intensity)
			{
				// lighting
				float3 lin = _LightColor1.rgb * intensity + _LightColor2.rgb * dif;     
				fixed4 col = fixed4(lerp(_CloudBaseColor1.rgb,  _CloudBaseColor2.rgb, den), den);

				col.rgb *= lin;
				col.a *= 0.3;
				col.rgb *= col.a;
				
				return sum + col * (1.0-sum.a);
			}

			fixed4 raymarching(float3 rOrigin, float3 rDirection, float depth, int steps)
			{
				float t = 0;
				float4 sum = float4(0,0,0,0);

				for (int i=0; i<steps; i++)
				{
					float3 pos = rOrigin + rDirection * t;
					if (t >_MaxDistance || t >= depth) 
					{
						sum = fixed4(0,0,0,0); // no alpha
						break;
					}
					float density = map(pos);

					if (density > 0.01)
					{
						float dif = saturate(map(pos * _WorldSpaceLightPos0));
						sum = integrate(sum, dif, density, _LightIntensity);
					}
					t += max(0.05, 0.03*t);
				}

				return sum;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
				depth *= length(i.ray);

				fixed4 background = tex2D(_MainTex, i.uv);

                float3 rayDirection = normalize(i.ray.xyz);
				float3 rayOrigin = _WorldSpaceCameraPos;
				fixed4 result = raymarching(rayOrigin, rayDirection, depth, 70);

				fixed4 col = fixed4(background * (1-result.a) + result.rgb * result.a, 1.0);
				return col;
            }
            ENDCG
        }
    }
}
