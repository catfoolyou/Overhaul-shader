#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D depthtex0;
uniform sampler2D colortex2;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform ivec2 eyeBrightnessSmooth;
uniform int worldTime;
uniform vec3 skyColor;

varying float id;
const int shadowMapResolution = 2048;   // Shadowmap resolution [512 1024 2048 4096]

varying vec3 normal;  
varying vec4 texcoord;
varying vec4 color;
varying vec4 lightMapCoord;
varying vec2 TexCoords;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying float isNight;

void main() {
	float Depth = texture2D(depthtex0, TexCoords).r;
    vec3 normal2 = normalize(normal) * 0.5 + 0.5;
	vec4 Albedo = texture2D(texture, TexCoords) * color;

	float Light = (eyeBrightnessSmooth.y / 10000.0) + (isNight) / 2.0;

	vec4 col = vec4(color.rgb, 0.4) * (texture2D(texture, texcoord.st) * vec4(skyColor, 1.0));

    gl_FragData[0] = col;
    gl_FragData[3] = vec4(normal2, 1.0);   // Normal
    
}