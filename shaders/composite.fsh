#version 120

varying vec2 TexCoords;
varying vec2 lmcoord;
varying vec4 texcoord;

// Direction of the sun (not normalized!)
uniform vec3 sunPosition;

// The color textures which we wrote to
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform sampler2D lightmap;
uniform sampler2D texture;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform int worldTime;
uniform float rainStrength; 
uniform ivec2 eyeBrightnessSmooth;
uniform vec3 skyColor;

/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/

const float sunPathRotation = -20.0f;
const int shadowMapResolution = 2048;   // Shadowmap resolution [512 1024 2048]
const float shadowDistance = 80;   // Shadow draw distance [60 80 100 120 140 160]
const int noiseTextureResolution = 32; 
const float eyeBrightnessHalflife = 0.1f;
const float shadowDistanceRenderMul = 1.0f;
const float ambientOcclusionLevel = 1.0f;

vec2 AdjustLightmap(in vec2 Lightmap){
    vec2 NewLightMap;
    NewLightMap.x = 2.0 * pow(Lightmap.x, 5.06);
    NewLightMap.y = pow(Lightmap.y, 4);
    return NewLightMap;
}

vec3 GetLightmapColor(in vec2 Lightmap){
    Lightmap = AdjustLightmap(Lightmap);
    // Color of the torch and sky.
    const vec3 TorchColor = vec3(2.5f, 1.0f, 0.25f);
    vec4 Albedo = texture2D(texture, TexCoords);
    const vec3 SkyColor = vec3(0.8f, 0.69f, 0.65f);
    // Add the lighting togther to get the total contribution of the lightmap the final color.
    return (Lightmap.x * TorchColor) + (Lightmap.y * SkyColor * (skyColor + 0.05f));
}

float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
    return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}

vec3 TransparentShadow(in vec3 SampleCoords){
    #define TransmittedColor (texture2D(shadowcolor0, SampleCoords.xy)).rgb * (1.0f - (texture2D(shadowcolor0, SampleCoords.xy)).a)
    return mix(TransmittedColor * Visibility(shadowtex1, SampleCoords), vec3(1.0f), Visibility(shadowtex0, SampleCoords));
}

vec2 DistortPosition(in vec2 position){
    return position / mix(1.0f, length(position), 0.9f);
}

#define SHADOW_SAMPLES 2

vec3 GetShadow(float depth) {
    vec4 ViewW = gbufferProjectionInverse * vec4(vec3(TexCoords, depth) * 2.0f - 1.0f, 1.0f);
    vec4 ShadowSpace = shadowProjection * shadowModelView * (gbufferModelViewInverse * vec4((ViewW.xyz / ViewW.w), 1.0f));
    ShadowSpace.xy = DistortPosition(ShadowSpace.xy);
    vec3 SampleCoords = ShadowSpace.xyz * 0.5f + 0.5f;
    #define RandomAngle texture2D(noisetex, TexCoords * 20.0f).r * 100.0f
    mat2 Rotation =  mat2(cos(RandomAngle), -(sin(RandomAngle)), sin(RandomAngle), cos(RandomAngle)) / shadowMapResolution;
    vec3 ShadowAccum = vec3(0.0f);
    for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++){
        for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++){
            ShadowAccum += TransparentShadow(vec3(SampleCoords.xy + (Rotation * vec2(x, y)), SampleCoords.z));
        }
    }
    ShadowAccum /= pow(2 * SHADOW_SAMPLES, 2);
    return ShadowAccum;
}

vec3 ACESFilm(vec3 x){
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp(((x*(a*x+b))/(x*(c*x+d)+e)), 0.0f, 1.0f);
}

void main(){
    #define Vibrance 1.4 * length(1.4)
    #define Albedo pow(texture2D(colortex0, TexCoords).rgb, vec3(Vibrance))
    #define Depth texture2D(depthtex0, TexCoords).r
    if(Depth == 1.0f){
        gl_FragData[0] = vec4(Albedo, 1.0f);
        return;
    }
    #define Lightmap texture2D(colortex2, TexCoords).rg
    #define LightmapColor GetLightmapColor(Lightmap)
    float shadowStrength = 0.0f;
    if(worldTime >= 12786 && worldTime < 23961){
        shadowStrength = 0.0f; // Night
    }
    if(worldTime >= 2000 && worldTime < 12000){
        shadowStrength = 1.0f; // Day
    }
    if(worldTime >= 12000 && worldTime < 12542){
        shadowStrength = (((12000 - worldTime) * 0.65f) / 542) + 1.0f; // Early evening
    }
    if(worldTime >= 12542 && worldTime < 12786){
        shadowStrength = (((12542 - worldTime) * 0.35f) / 244) + 0.35f; // Late evening
    }
    if(worldTime >= 167 && worldTime < 2000){
        shadowStrength = (((worldTime - 167) * 0.65f) / 1833) + 0.35f; // Late morning
    }
    if(worldTime >= 23961 && worldTime < 24000){
        shadowStrength = ((worldTime - 23961)) / 39; // Early morning 1
    }
    if(worldTime >= 0 && worldTime < 167){
        shadowStrength = ((worldTime * 0.284f) / 167) + 0.066f; // Early morning 2
    }
    if(rainStrength > 0){
        shadowStrength = min(mix(1, 0.05, rainStrength), shadowStrength); // Rain
    }
    #define Normal normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f)
    float NdotL = max(dot(Normal * shadowStrength, normalize(sunPosition)), 0.0f);
    if(worldTime >= 12786 && worldTime < 23961){
        NdotL = shadowStrength;
    }
    #define Ambient max(shadowStrength - 1.5f, 0)
    #define Diffuse Albedo * (LightmapColor + NdotL * GetShadow(Depth) + Ambient) // lmcoord.y
    /* DRAWBUFFERS:0 */
    // Finally write the diffuse color
    gl_FragData[0] = vec4(ACESFilm(Diffuse), lmcoord.y);
}
