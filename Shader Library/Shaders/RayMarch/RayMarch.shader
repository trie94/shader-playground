Shader "Hidden/RayMarch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Cull Off ZWrite Off ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma target 3.0

            #include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "DistanceFunctions.cginc"
			
            sampler2D _MainTex;
			uniform sampler2D _CameraDepthTexture;
			uniform float4x4 _CamFrustum;
			uniform float4x4 _CamToWorld;
			uniform float _MaxDistance;
			uniform float3 _ModInterval;

			uniform float4 _Sphere1;
			uniform float4 _Sphere2;
			uniform float4 _Box1;

			uniform float _Box1Round;
			uniform float _BoxSphereSmooth;
			uniform float _SphereIntersectSmooth;

			uniform fixed4 _MainColor;

			uniform float _LightIntensity;
			uniform float _ShadowIntensity;
			uniform float2 _ShadowDistance;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 ray :TEXCOORD1;
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
				o.ray = mul(_CamToWorld, o.ray);

                return o;
            }

			float BoxSphere(float3 pos)
			{
				float sphere1 = sdSphere(pos - _Sphere1.xyz, _Sphere1.w);
				float box1 = sdRoundBox(pos - _Box1.xyz, _Box1.www, _Box1Round);
				float combine1 = opSS(sphere1, box1, _BoxSphereSmooth);
				float sphere2 = sdSphere(pos - _Sphere2.xyz, _Sphere2.w);
				float combine2 = opIS(sphere2, combine1, _SphereIntersectSmooth);

				return combine2;
			}

			float distanceField(float3 pos)
			{
				//float modX = pMod1(pos.x, _ModInterval.x);
				//float modY = pMod1(pos.y, _ModInterval.y);
				//float modZ = pMod1(pos.z, _ModInterval.z);
				float ground = sdPlane(pos, float4(0,1,0,0));
				float boxSphere = BoxSphere(pos);

				return opU(ground, boxSphere);
			}

			float3 getNormal(float3 pos)
			{
				const float2 offset = float2(0.001, 0);
				float3 n = float3(
					distanceField(pos+offset.xyy)-distanceField(pos-offset.xyy),
					distanceField(pos+offset.yxy)-distanceField(pos-offset.yxy),
					distanceField(pos+offset.yyx)-distanceField(pos-offset.yyx));
				return normalize(n);
			}

			float hardShadow(float3 rayOrigin, float3 rayDirection, float mint, float maxt)
			{
				for (float t = mint; t < maxt;)
				{
					float h = distanceField(rayOrigin+rayDirection*t);
					if (h < 0.001)
					{
						return 0.0;
					}
					t += h;
				}

				return 1.0;
			}

			float3 shading(float3 pos, float3 normal)
			{
				float3 result = (_LightColor0 * (saturate(dot(_WorldSpaceLightPos0, normal)))) * _LightIntensity;
				float shadow = hardShadow(pos, _WorldSpaceLightPos0, _ShadowDistance.x, _ShadowDistance.y) * 0.5 + 0.5;
				shadow = max(0, pow(shadow, _ShadowIntensity));
				result *= shadow;

				return result;
			}

			fixed4 raymarching(float3 rOrigin, float3 rDirection, float depth)
			{
				fixed4 result;
				const int max_iteration = 64;
				float t = 0;	// distance travel along the ray direction

				for (int i=0; i<max_iteration; i++)
				{
					if (t >_MaxDistance || t >= depth)
					{
						// draw environment, because there is no hit
						result = fixed4(rDirection,0);
						return result;
					}

					float3 pos = rOrigin + rDirection * t;
					// check for hit in distance field
					float distance = distanceField(pos);

					// we have hit something
					if (distance < 0.01)
					{
						// shading
						float3 n = getNormal(pos);
						float3 shade = shading(pos, n);
						// result = fixed4(_MainColor.rgb * shade, 1);
						result = fixed4(shade, 1);
						break;
					}

					t += distance;
				}

				return result;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
				depth *= length(i.ray);

				fixed4 col = tex2D(_MainTex, i.uv);
                float3 rayDirection = normalize(i.ray.xyz);
				float3 rayOrigin = _WorldSpaceCameraPos;
				fixed4 result = raymarching(rayOrigin, rayDirection, depth);

				return fixed4(col * (1-result.w) + result.xyz * result.w, 1.0);
            }
            ENDCG
        }
    }
}
