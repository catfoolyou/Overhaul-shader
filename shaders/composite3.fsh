#version 120

uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

varying vec2 TexCoords;
uniform float near;
uniform float far;

uniform float viewWidth;
uniform float viewHeight;
uniform int worldTime;
uniform vec3 skyColor;
uniform vec3 cameraPosition;
uniform float rainStrength;
uniform int isEyeInWater;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 hPos = projectionMatrix * vec4(position, 1.0);
	return hPos.xyz / hPos.w;
}

vec3 skyColorArr[24] = vec3[24](
    vec3(0.104, 0.26, 0.507),        // 0-1000
    vec3(0.104, 0.26, 0.507),        // 1000 - 2000
    vec3(0.104, 0.26, 0.507),        // 2000 - 3000
    vec3(0.104, 0.26, 0.507),        // 3000 - 4000
    vec3(0.104, 0.26, 0.507),        // 4000 - 5000 
    vec3(0.104, 0.26, 0.507),        // 5000 - 6000
    vec3(0.104, 0.26, 0.507),        // 6000 - 7000
    vec3(0.104, 0.26, 0.507),        // 7000 - 8000
    vec3(0.104, 0.26, 0.507),        // 8000 - 9000
    vec3(0.104, 0.26, 0.507),        // 9000 - 10000
    vec3(0.104, 0.26, 0.507),        // 10000 - 11000
    vec3(0.104, 0.26, 0.507),        // 11000 - 12000
    vec3(0.104, 0.26, 0.507),        // 12000 - 13000
    vec3(0.02, 0.02, 0.027),      // 13000 - 14000
    vec3(0.02, 0.02, 0.027),      // 14000 - 15000
    vec3(0.02, 0.02, 0.027),      // 15000 - 16000
    vec3(0.02, 0.02, 0.027),      // 16000 - 17000
    vec3(0.02, 0.02, 0.027),      // 17000 - 18000
    vec3(0.02, 0.02, 0.027),      // 18000 - 19000
    vec3(0.02, 0.02, 0.027),      // 19000 - 20000
    vec3(0.02, 0.02, 0.027),      // 20000 - 21000
    vec3(0.02, 0.02, 0.027),      // 21000 - 22000
    vec3(0.02, 0.02, 0.027),      // 22000 - 23000
    vec3(0.02, 0.02, 0.027)       // 23000 - 24000(0)
);

void main()
{
	float isNight = 0.0;  // daytime
    if(12000<worldTime && worldTime<13000) {
        isNight = 1.0 - (13000-worldTime) / 1000.0; // evening
    }
    else if(13000<=worldTime && worldTime<=23000) {
        isNight = 1.0;    // Night
    }
    else if(23000<worldTime) {
        isNight = (24000-worldTime) / 1000.0;   // Dawn
    }

	int hour = worldTime/1000;
    int next = (hour+1<24)?(hour+1):(0);
    float delta = float(worldTime-hour*1000)/1000;
    vec3 sky = mix(skyColorArr[hour], skyColorArr[next], delta);

	float contrast = mix(1.001, 1.0, isNight);
	float Depth = texture2D(depthtex0, TexCoords).r;

	vec3 screenPos = vec3(TexCoords, texture2D(depthtex0, TexCoords).x);
	vec3 ndcPos = screenPos * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
	
	vec3 color = texture2D(gcolor, TexCoords).rgb;
	color = (color - 0.5) * contrast + 0.5;

	vec3 fog = mix(sky, vec3(0.7), isNight);
	fog = mix(fog, vec3(0.76, 0.85, 0.94), 0.5);

	float dist = distance(viewPos, vec3(0.0));
	float fogdist = mix(dist / far * 0.1, dist / (far * 1.5), rainStrength);
	
	vec3 fogcolor = mix(color, fog, fogdist);

	if(Depth == 1.0f){
        gl_FragData[0] = vec4(color, 1.0);
        return;
    }

    gl_FragColor = vec4(mix(fogcolor, color, isNight), 1.0);
}

/*
saturation is luminance * saturation + color * (1.0 - saturation) 
contrast is (color - 0.5) * contrast + 0.5
*/