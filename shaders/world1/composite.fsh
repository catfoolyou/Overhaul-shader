#version 120

varying vec2 TexCoords;
varying vec2 lmcoord;
varying vec4 texcoord;

uniform vec3 sunPosition;

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
uniform vec3 cameraPosition;
uniform float far;

/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/


#define SHADOW_SAMPLES 2

const float sunPathRotation = -20.0f;
const int shadowMapResolution = 2048;   // Shadowmap resolution [512 1024 2048 4096]
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
	vec4 Albedo = texture2D(texture, TexCoords);

    vec3 TorchColor = vec3(0.94, 0.00, 1.00);
    vec3 SkyColor = vec3(0.61, 0.00, 1.00);
	
	TorchColor += vec3(1.5);

	return (Lightmap.x * TorchColor) + (Lightmap.y * SkyColor);

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

vec3 reinhard(vec3 v)
{
    return v / (1.0f + v);
}

void main(){
    #define Vibrance 1.35
    #define Albedo pow(texture2D(colortex0, TexCoords).rgb, vec3(Vibrance * length(Vibrance)))
    #define Depth texture2D(depthtex0, TexCoords).r
    if(Depth == 1.0f){
        gl_FragData[0] = vec4(Albedo, 1.0f);
        return;
    }
    #define Lightmap texture2D(colortex2, TexCoords).rg
    #define LightmapColor GetLightmapColor(Lightmap)
    float shadowStrength = 0.05f;
    #define Normal normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f)
    float NdotL = max(dot(Normal * shadowStrength, normalize(sunPosition)), 0.0f);
    #define Diffuse Albedo * (LightmapColor + NdotL * GetShadow(Depth) + 0.03) // lmcoord.y
    /* DRAWBUFFERS:0 */
    // Finally write the diffuse color
    gl_FragData[0] = vec4(ACESFilm(Diffuse), lmcoord.y);
}
