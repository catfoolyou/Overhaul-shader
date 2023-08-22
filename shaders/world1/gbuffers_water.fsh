#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;

uniform int worldTime;

varying float id;

varying vec3 normal;  
varying vec4 texcoord;
varying vec4 color;
varying vec4 lightMapCoord;

void main() {
    vec4 light = texture2D(lightmap, lightMapCoord.st); 
    vec3 normal2 = normalize(normal);
    normal2 = normal2 * 0.5 + 0.5;
    vec3 sky = vec3(0.104, 0.26, 0.507);
	vec4 col = vec4((color).rgb, 0.99);
    gl_FragData[0] = col * texture2D(texture, texcoord.st) * light; 
    gl_FragData[3] = vec4(normal2, 1.0);   // Normal
    
}