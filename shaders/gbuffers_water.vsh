#version 120

attribute vec2 mc_Entity;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

uniform int worldTime;
uniform float frameTimeCounter;

varying float id;

varying vec3 normal;

varying vec4 texcoord;
varying vec4 lightMapCoord;
varying vec4 color;

vec3 wave_move(vec3 pos) {
  float timer = (frameTimeCounter) * 3.141592;
  pos = mod(pos, 3.141592);
  vec2 wave_x = vec2(timer * 0.5, timer) + pos.xy;
  vec2 wave_z = vec2(timer, timer * 1.5) + pos.xy;
  vec2 wave_y = vec2(timer * 0.5, timer * 0.25) - pos.zx;

  wave_x = sin(wave_x + wave_y);
  wave_z = cos(wave_z + wave_y);
  return vec3(wave_x.x + wave_x.y, 0.0, wave_z.x + wave_z.y);
}

void main() {
    gl_Position = ftransform();
    vec4 positionInViewCoord = gl_ModelViewMatrix * gl_Vertex;
    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    
    gl_Position = gbufferProjection * positionInViewCoord;
	
    color = gl_Color;
    id = mc_Entity.x;
    if (mc_Entity.x == 10119){
        position.y += wave_move(position.xyz).z / 30;
        gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
    }
    normal = normalize(gl_NormalMatrix * gl_Normal);
    lightMapCoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
}