Shader "Unlit/furCat"
{
    Properties
    {
        _MainTex ("Fur Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 0, 0, 1)
        _RimColor ("Rim Color", Color) = (1, 0, 0, 1)
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _FurLength ("Fur Length", Range(0.0, 0.1)) = 0.0
        _FurShading ("Fur Shading", Range(0.0, 1.0)) = 0.0
        _FurDensity ("Fur Density", Range(1.0, 500.0)) = 1.0
        _Shininess ("Shininess", Range(1.0, 30.0)) = 1.0
        _RimPower ("Rim Power", Range(0.05, 5.0)) = 1.0
        _LocalForce ("Local Force", Vector) = (0, -1, 0, 0)
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
            #define FURSTEP 0.05
            #include "fur.cginc"
            
            ENDCG 
        }

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.10
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.15
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.20
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.25
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.30
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.35
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.40
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.45
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.50
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.55
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.60
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.65
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.70
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.75
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.80
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.85
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.90
            #include "fur.cginc"
            
            ENDCG
            
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 0.95
            #include "fur.cginc"
            
            ENDCG
            
        }

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_base
            #pragma fragment frag_base
            #define FURSTEP 1.00
            #include "fur.cginc"
            
            ENDCG
            
        }
    }
}
