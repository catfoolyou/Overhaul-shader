#version 120

#define NotDefaultWaterTexture
uniform sampler2D texture;
uniform sampler2D lightmap;

uniform int worldTime;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform ivec2 eyeBrightness;

varying float id;

varying vec3 normal;    // Normal vector in eye coordinate system

varying vec4 texcoord;
varying vec4 color;
varying vec4 lightMapCoord;

void main() {
    vec4 light = texture2D(lightmap, lightMapCoord.st); // Illumination
    vec3 norm = normalize(normal);
    norm = norm * 0.5 + 0.5;
    vec3 sky = vec3(0.104, 0.26, 0.507);
    if(id!=10119) {
        gl_FragData[0] = color * texture2D(texture, texcoord.st) * light;   // If it is not a water surface, the texture is drawn normally
        gl_FragData[3] = vec4(norm, 1.0);   // Normal
    }
    else {  
        gl_FragData[0] = vec4(mix(vec3(0.02, 0.18, 0.26), sky, 0.5), 0.4) * light;   // Primary Color
        gl_FragData[3] = vec4(norm, 1.0);   // Normal
    }
}