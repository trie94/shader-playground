Shader "Unlit/furCat"
{
    Properties
    {
        _MainTex ("Fur Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 0, 0, 1)
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _FurLength ("Fur Length", Range(1.0, 5.0)) = 1.0
        _FurShading ("Fur Shading", Range(1.0, 5.0)) = 1.0
        _FurDensity ("Fur Density", Range(1.0, 500.0)) = 1.0
        _Shininess ("Shininess", Range(1.0, 30.0)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_surface
            #pragma fragment frag_surface
            #define FURSTEP 0.00
            #include "fur.cginc"
            
            ENDCG 
        }

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.00
            #include "fur.cginc"
            
            ENDCG 
        }
    }
}
