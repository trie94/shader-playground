Shader "Custom/fire"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _mainTex ("Main (RGB)", 2D) = "white" {}
        _smokeTex ("Smoke (RGB)", 2D) = "white" {}
        _noiseTex ("Noise (RGB)", 2D) = "white" {}
        _Speed ("FireSpeed", Range(0.0, 1.0)) = 0.7
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _mainTex;
        sampler2D _smokeTex;
        sampler2D _noiseTex;

        struct Input
        {
            float2 uv_mainTex;
            float2 uv_smokeTex;
            float2 uv_noiseTex;
        };

        // fixed4 _Color;
        float _Speed;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 smoke = tex2D (_smokeTex, float2(IN.uv_smokeTex.x, IN.uv_smokeTex.y-_Time.y * _Speed * 0.5));
            fixed4 noise = tex2D (_noiseTex, float2(IN.uv_noiseTex.x, IN.uv_noiseTex.y-_Time.y * _Speed));
            fixed4 mainColor = tex2D (_mainTex, IN.uv_mainTex + noise.r);
            o.Emission = mainColor.rgb * 0.9;
            o.Alpha = mainColor.a * smoke.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
