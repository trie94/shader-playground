#pragma target 3.0

#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "noise.cginc"

sampler2D _MainTex;
fixed4 _Color;
fixed4 _RimColor;
fixed4 _Specular;
half _Shininess;
float _FurLength;
float _FurShading;
float _FurDensity;
float _RimPower;
float4 _MainTex_ST;
float3 _LocalForce;

struct appdata
{
    float4 vertex : POSITION;
    float4 uv : TEXCOORD0;
    float3 worldNormal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    float3 normal : NORMAL;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 localPos : TEXCOORD1;
    float3 worldNormal : TEXCOORD2;
    float3 worldPos : TEXCOORD3;
};

v2f vert_surface(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.localPos = v.vertex;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    
    return o;
}

v2f vert_base(appdata v)
{
    v2f o;
    float3 P = v.vertex.xyz + v.normal * _FurLength * FURSTEP;
    P += clamp(_LocalForce.xyz, -5, 5) * _FurLength * pow(FURSTEP, 4);
    o.vertex = UnityObjectToClipPos(float4(P, 1.0));
    // o.vertex = UnityObjectToClipPos(v.vertex);
    o.localPos = v.vertex;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);    

    return o;
}

fixed4 frag_surface(v2f i): SV_Target
{
    float3 worldNormal = normalize(i.worldNormal);
    float3 projNormal = saturate(pow(worldNormal*1.5, 4));

    float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    float3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    float3 worldHalf = normalize(worldView + worldLight);
    
    half3 albedo0 = tex2D(_MainTex, i.localPos.xy).rgb;
    half3 albedo1 = tex2D(_MainTex, i.localPos.zx).rgb;
    half3 albedo2 = tex2D(_MainTex, i.localPos.zy).rgb;
    
    float3 albedo;
    albedo = lerp(albedo1, albedo0, projNormal.z);
    albedo = lerp(albedo, albedo2, projNormal.x);

    fixed3 ambient = unity_AmbientSky.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

    fixed3 color = albedo + diffuse + specular;

    return fixed4(color, 1.0);
}

fixed4 frag_base(v2f i): SV_Target
{
    fixed3 worldNormal = normalize(i.worldNormal);
    float3 projNormal = saturate(pow(worldNormal*1.5, 4));

    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);

    half3 albedo0 = tex2D(_MainTex, i.localPos.xy).rgb;
    half3 albedo1 = tex2D(_MainTex, i.localPos.zx).rgb;
    half3 albedo2 = tex2D(_MainTex, i.localPos.zy).rgb;
    
    float3 albedo;
    albedo = lerp(albedo1, albedo0, projNormal.z);
    albedo = lerp(albedo, albedo2, projNormal.x);

    float shadow = lerp(1, FURSTEP, _FurShading);
    albedo *= shadow;

    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

    fixed3 color = albedo + diffuse + specular;
    fixed alpha = saturate(snoise(i.localPos.xyz * _FurDensity));

    float rim = saturate(1-dot(worldView, worldNormal));
    rim = pow(rim, _RimPower);
    color = lerp(color, _RimColor.rgb, rim * _RimColor.a);
    
    return fixed4(color, alpha);
}
