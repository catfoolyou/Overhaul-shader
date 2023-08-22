#version 120

#define WavingWater
#define WavingWaterStrength 0.04 //[0.02 0.04 0.06 0.08 1.0]
#define WavingWaterSize 1.2 //[0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define WavingWaterSpeed 1.2 //[0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define ReflectionQuality 1.0 //[0.04 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.8 1.0]
#define ReflectionDistance 160 //[20 30 40 50 60 80 120 160 200 400 800 1600 3200]
#define ReflectionCoefficient 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

const int noiseTextureResolution = 128;
uniform sampler2D noisetex;

uniform float near;
uniform float far;
uniform sampler2D colortex3;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform int worldTime;
uniform float frameTimeCounter;

varying float isNight;
varying vec3 mySkyColor;
varying vec3 mySunColor;

varying vec4 texcoord;


vec2 getScreenCoordByViewCoord(vec3 viewCoord) {
    vec4 p = vec4(viewCoord, 1.0);
    p = gbufferProjection * p;
    p /= p.w;
    p = p * 0.5f + 0.5f;
    return p.st;
}
vec2 getScreenCoordByViewCoord_(vec3 viewCoord) {
    vec4 p = vec4(viewCoord, 1.0);
    p = gbufferProjection * p;
    p /= p.w;
    if(p.z < -1 || p.z > 1)
        return vec2(-1.0);
    p = p * 0.5f + 0.5f;
    return p.st;
}

float linearizeDepth(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

float getLinearDepthOfViewCoord(vec3 viewCoord) {
    vec4 p = vec4(viewCoord, 1.0);
    p = gbufferProjection * p;
    p /= p.w;
    return linearizeDepth(p.z * 0.5 + 0.5);
}

vec3 drawSky(vec3 positionInViewCoord) {
    // The distance from a point in the eye coordinate system to the sun.
    float disToSun = 1.0 - dot(normalize(positionInViewCoord.xyz), normalize(sunPosition));     // Sun
    float disToMoon = 1.0 - dot(normalize(positionInViewCoord.xyz), normalize(moonPosition));    // Moon

    // The fog and the sun mix colors.
    float sunMixFactor = clamp(1.0 - disToSun, 0, 1) * (1.0-isNight);
    vec3 finalColor = mix(mySkyColor, mySunColor, pow(sunMixFactor, 4));

    // The fog and the moon blend.
    float moonMixFactor = clamp(1.0 - disToMoon, 0, 1) * isNight;
    finalColor = mix(finalColor, mySunColor, pow(moonMixFactor, 4));

    return finalColor;
}

vec3 waterRayTarcing(vec3 startPoint, vec3 direction, vec3 color) {
	vec3 dir = direction;
    const float stepBase = ReflectionQuality;
    vec3 testPoint = startPoint;
    direction *= stepBase * 0.8;
    vec3 hitColor = vec3(0.0);
    int step = ReflectionDistance;
    for(int i = 0; i < step; i++)
    {
        testPoint += direction * (direction.y + float(i) * 0.05);
        vec2 uv = getScreenCoordByViewCoord(testPoint);
        if(uv.x<0 || uv.x>1 ||
          uv.y<0 || uv.y>1) {
            break;
        }
        float sampleDepth = texture2DLod(depthtex0, uv, 0.0).x;
        sampleDepth = linearizeDepth(sampleDepth);
		sampleDepth -= 10;
        float testDepth = getLinearDepthOfViewCoord(testPoint);
        
        if((sampleDepth < testDepth && testDepth - sampleDepth < (1.0 + testDepth * 200.0 + float(i))/2048.0 ) || i == step - 1.0)
        {
            hitColor = texture2DLod(colortex0, uv, 0.0).rgb;
            return hitColor;
        }
    }

	hitColor.rgb = mix(drawSky(dir), hitColor.rgb, 0.4);  
    return hitColor;
}

float getWave(vec4 positionInWorldCoord) {
	float Size = 2.2 - WavingWaterSize;
	float Speed = 2.2 - WavingWaterSpeed;
    // Small Wave
    float speed1 = float(worldTime) / (noiseTextureResolution * 5 * Speed);
    vec3 coord1 = positionInWorldCoord.xyz / noiseTextureResolution;
    coord1.x *= 6 * Size;
    coord1.x += speed1;
    coord1.z += speed1 * 0.4 * Size;
    float noise1 = texture2D(noisetex, coord1.xz).x;
	return noise1;
	
    // Mixed Wave
    float speed2 = float(worldTime) / (noiseTextureResolution * 7);
    vec3 coord2 = positionInWorldCoord.xyz / noiseTextureResolution;
    coord2.x *= 0.5;
    coord2.x -= speed2 * 0.15 + noise1 * 0.05;
    coord2.z -= speed2 * 0.7 - noise1 * 0.05;
    float noise2 = texture2D(noisetex, coord2.xz).x;

    return noise2;

}

vec3 waterEffect(vec3 color, vec2 uv, vec3 viewPos, vec4 positionInWorldCoord, vec4 water) {
    float attr = water.w;
    if(attr >= 0.5)
    {
        vec3 normal = water.xyz * 2 - 1;
        
        positionInWorldCoord.xyz += cameraPosition; // To world coordinates (absolute coordinates)
        
        // Wave Coefficient
        #ifdef WavingWater
        if(attr == 1.0) {
            float wave = getWave(positionInWorldCoord);
            wave = wave * 2 - 1;
            normal.x += WavingWaterStrength * wave;
            normal.z += WavingWaterStrength * wave;
    		normal = normalize(normal);
    	}
        #endif
        vec3 viewPos_ = normalize(viewPos.xyz);
        float angle = abs(dot(viewPos_, normal));
        
        vec3 viewRefRay = reflect(viewPos_, normal);
        vec3 reflectColor = waterRayTarcing(viewPos, viewRefRay, color);
        
        reflectColor = mix(reflectColor, color, angle);
    	color = mix(color, reflectColor, ReflectionCoefficient);
    	
    }
    return color;
}

vec3 getBloomSource(vec3 color) {
	float brightness = color.r*0.3 + color.g*0.6 + color.b*0.1;
	if(brightness < 0.6)
	{
		return vec3(0);
	}
	return color;
}

void main(){
    vec3 color = texture2D(colortex0, texcoord.st).rgb;
    vec4 attrs = texture2D(colortex3, texcoord.st);
    
    // Coordinate transformation of square with water surface
    float depth0 = texture2D(depthtex0, texcoord.st).x;
    vec4 positionInNdcCoord0 = vec4(texcoord.st*2-1, depth0*2-1, 1);
    vec4 positionInClipCoord0 = gbufferProjectionInverse * positionInNdcCoord0;
    vec4 positionInViewCoord0 = vec4(positionInClipCoord0.xyz/positionInClipCoord0.w, 1.0);
    vec4 positionInWorldCoord0 = gbufferModelViewInverse * positionInViewCoord0;

    color = waterEffect(color, texcoord.st, positionInViewCoord0.xyz, positionInWorldCoord0, attrs);

    gl_FragData[0] = vec4(color, 1.0);

}