#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D depthtex0;

uniform int worldTime;

varying float id;

varying vec3 normal;  
varying vec4 texcoord;
varying vec4 color;
varying vec4 lightMapCoord;
varying vec2 TexCoords;

varying float isNight;

void main() {
    vec4 light = texture2D(lightmap, lightMapCoord.st); 
    vec3 normal2 = normalize(normal) * 0.5 + 0.5;
	vec4 Albedo = texture2D(texture, TexCoords) * color;

    //vec3 sky = vec3(0.104, 0.26, 0.507);
	vec4 col = vec4((color).rgb, 1.0) * texture2D(texture, texcoord.st) * light;

    gl_FragData[0] = col;
    gl_FragData[3] = vec4(normal2, 1.0);   // Normal
    
}