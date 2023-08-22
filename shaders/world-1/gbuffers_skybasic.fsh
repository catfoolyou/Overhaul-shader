#version 120

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform ivec2 eyeBrightness;
uniform int worldTime;
uniform float rainStrength;


varying vec4 starData;


#define WATER_COLOR vec3(0.018, 0.12 , 0.18)

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	
	vec3 color = vec3(1.00, 0.50, 0.00);
	return color;
}

void main() {
	vec3 color;
	vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
	pos = gbufferProjectionInverse * pos;
	color = calcSkyColor(normalize(pos.xyz));
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}