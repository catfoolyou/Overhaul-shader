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

vec3 sunColorArr[24] = vec3[24](
    vec3(2, 2, 1),      // 0-1000
    vec3(2, 1.5, 1),    // 1000 - 2000
    vec3(1, 1, 1),      // 2000 - 3000
    vec3(1, 1, 1),      // 3000 - 4000
    vec3(1, 1, 1),      // 4000 - 5000 
    vec3(1, 1, 1),      // 5000 - 6000
    vec3(1, 1, 1),      // 6000 - 7000
    vec3(1, 1, 1),      // 7000 - 8000
    vec3(1, 1, 1),      // 8000 - 9000
    vec3(1, 1, 1),      // 9000 - 10000
    vec3(1, 1, 1),      // 10000 - 11000
    vec3(1, 1, 1),      // 11000 - 12000
    vec3(2, 1.5, 0.5),      // 12000 - 13000
    vec3(0.3, 0.5, 0.9),      // 13000 - 14000
    vec3(0.3, 0.5, 0.9),      // 14000 - 15000
    vec3(0.3, 0.5, 0.9),      // 15000 - 16000
    vec3(0.3, 0.5, 0.9),      // 16000 - 17000
    vec3(0.3, 0.5, 0.9),      // 17000 - 18000
    vec3(0.3, 0.5, 0.9),      // 18000 - 19000
    vec3(0.3, 0.5, 0.9),      // 19000 - 20000
    vec3(0.3, 0.5, 0.9),      // 20000 - 21000
    vec3(0.3, 0.5, 0.9),      // 21000 - 22000
    vec3(0.3, 0.5, 0.9),      // 22000 - 23000
    vec3(0.3, 0.5, 0.9)       // 23000 - 24000(0)
);

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

varying vec4 starData;

float fogify(float x, float w) {
	return w / (x * x + w);
}

/*float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

// Function to generate cloud coverage
float generateCloudCoverage(vec2 p) {
    float cloudDensity = 0.5;  // Adjust cloud density as needed
    float cloudScale = 10.0;   // Adjust cloud scale as needed

    float cloudValue = noise(p * cloudScale);
    return cloudDensity * cloudValue;
}*/

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);

	float isNight;
	vec3 sky;
	vec3 fog;

	//vec2 cloudPosition = pos.xz;
    //float cloudCoverage = generateCloudCoverage(cloudPosition);

	int hour = worldTime/1000;
    int next = (hour+1<24)?(hour+1):(0);
    float delta = float(worldTime-hour*1000)/1000;
    sky = mix(skyColorArr[hour], skyColorArr[next], delta);
    fog = mix(sunColorArr[hour], sunColorArr[next], delta);

    // Alternate Day and night interpolation
    isNight = 0;  // daytime
    if(12000<worldTime && worldTime<13000) {
        isNight = 1.0 - (13000-worldTime) / 1000.0; // evening
    }
    else if(13000<=worldTime && worldTime<=23000) {
        isNight = 1.0;    // Night
    }
    else if(23000<worldTime) {
        isNight = (24000-worldTime) / 1000.0;   // Dawn
    }
	
	vec3 rainColor = vec3(0.2) - vec3((isNight) / 2.0);

    // Weather Gradient
    sky = mix(sky, rainColor, rainStrength);
    fog = mix(fog, rainColor, rainStrength);

	fog = mix(fog, vec3(0.76, 0.85, 0.94), 0.7);
	//vec3 cloudColor = vec3(1.0);
	//sky = mix(sky, cloudColor, cloudCoverage);
	
	vec3 color = mix(mix(sky, skyColor, isNight), mix(fog, fogColor, isNight), fogify(max(upDot, 0.0), 0.25));

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