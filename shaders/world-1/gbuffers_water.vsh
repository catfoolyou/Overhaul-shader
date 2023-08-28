#version 120

attribute vec2 mc_Entity;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

uniform int worldTime;

varying float id;

varying vec3 normal;

varying vec4 texcoord;
varying vec4 lightMapCoord;
varying vec4 color;
varying vec2 TexCoords;

varying float isNight;

void main() {
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

    vec4 positionInViewCoord = gl_ModelViewMatrix * gl_Vertex;
    TexCoords = gl_MultiTexCoord0.st;
    gl_Position = gbufferProjection * positionInViewCoord;

    vec3 sky = vec3(0.104, 0.26, 0.507);
    id = mc_Entity.x;

    normal = normalize(gl_NormalMatrix * gl_Normal);
    lightMapCoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;

    if(id!=10119) {
        color = gl_Color;   // Normal
    }
     else {   
        color = vec4(mix(vec3(0.02, 0.02, 0.027), sky, 0.5), 0.4);
    }
}