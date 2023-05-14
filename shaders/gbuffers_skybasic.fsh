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

float fogify(float x, float w) {
	return w / (x * x + w);
}

#define WATER_COLOR vec3(0.018, 0.12 , 0.18)

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);

	vec3 fog = vec3(0.76, 0.85, 0.94);
	vec3 sky = vec3(0.104, 0.26, 0.507);

	vec3 rfog = vec3(0.70, 0.70, 0.70);
	vec3 rsky = vec3(0.20, 0.20, 0.20);

	float mixStrength = 0.1;
	if(worldTime >= 12786 && worldTime < 23961){
        	mixStrength = 0.0; // Night
    	}
   	if(worldTime >= 2000 && worldTime < 12000){
        	mixStrength = 1.0; // Day
    	}
    	if(worldTime >= 12000 && worldTime < 12542){
        	mixStrength = (((12000 - worldTime) * 0.65f) / 542) + 1.0f; // Early evening
    	}
    	if(worldTime >= 12542 && worldTime < 12786){
        	mixStrength = (((12542 - worldTime) * 0.35f) / 244) + 0.35f; // Late evening
    	}
    	if(worldTime >= 167 && worldTime < 2000){
        	mixStrength = (((worldTime - 167) * 0.65f) / 1833); // Late morning
    	}
    	if(worldTime >= 23961 && worldTime < 24000){
        	mixStrength = ((worldTime - 23961) * 0.066f) / 39; // Early morning 1
    	}
    	if(worldTime >= 0 && worldTime < 167){
       		mixStrength = ((worldTime * 0.284f) / 167); // Early morning 2
    	}
		if(rainStrength > 0){
			sky = mix(sky, rsky, rainStrength);
			fog = mix(fog, rfog, rainStrength);
		}
	mixStrength = clamp(mixStrength, 0.1, 1.0);
	mixStrength = 1.0 - mixStrength;
	vec3 color = mix(mix(sky, skyColor, mixStrength), mix(fog, fogColor, mixStrength), fogify(max(upDot, 0.0), 0.25));
	return color;
}

void main() {
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb;
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = calcSkyColor(normalize(pos.xyz));
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}