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
uniform vec3 fogColor;
uniform vec3 cameraPosition;
uniform float rainStrength;
uniform int isEyeInWater;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 hPos = projectionMatrix * vec4(position, 1.0);
	return hPos.xyz / hPos.w;
}

void main()
{
	float Depth = texture2D(depthtex0, TexCoords).r;

	vec3 screenPos = vec3(TexCoords, texture2D(depthtex0, TexCoords).x);
	vec3 ndcPos = screenPos * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
	
	vec3 color = texture2D(gcolor, TexCoords).rgb;
	color = (color - 0.5) * 0.99 + 0.5;

	vec3 fog = fogColor - vec3(0.01);

	float dist = distance(viewPos, vec3(0.0));
	
	vec3 fogcolor = mix(color, fog, dist / 500.0);

	if(Depth == 1.0f){
        gl_FragData[0] = vec4(color, 1.0);
        return;
    }

    gl_FragColor = vec4(fogcolor, 1.0);
}

/*
saturation is luminance * saturation + color * (1.0 - saturation) 
contrast is (color - 0.5) * contrast + 0.5
*/