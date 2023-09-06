#version 120

varying vec2 TexCoords;
varying vec2 LightmapCoords;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform float frameTimeCounter;
varying vec3 Normal;
varying vec4 Color;
attribute vec4 mc_Entity;

varying float id;

#define WAVY

vec3 wave_move(vec3 pos, float maxHeight) {
  float timer = (frameTimeCounter) * 3.141592;
  float grassOffset = 0.0; // Adjust the offset to desynchronize the grass movement
  float grassTimer = timer + grassOffset;

  pos = mod(pos, 3.141592);
  vec2 wave_x = vec2(timer * 0.5, timer) + pos.xy;
  vec2 wave_z = vec2(timer, timer * 1.5) + pos.xy;
  vec2 wave_y = vec2(timer * 0.5, timer * 0.25) - pos.zx;

  if (pos.y <= maxHeight) {
    wave_x = sin(wave_x + wave_y);
    wave_z = cos(wave_z + wave_y + grassTimer); // Apply the offset to desynchronize grass movement
    return vec3(wave_x.x + wave_x.y, 0.0, wave_z.x + wave_z.y);
  }
  
  return pos;
}


void main() {
    // Transform the vertex
    gl_Position = ftransform();
    // Assign values to varying variables
    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
    TexCoords = gl_MultiTexCoord0.st;
	id = mc_Entity.x;
	#ifdef WAVY
    if (mc_Entity.x == 10031 || mc_Entity.x == 10059 || mc_Entity.x == 10175 || mc_Entity.x == 10176 || mc_Entity.x == 10177 || mc_Entity.x == 10018){
        position.xz += wave_move(position.xyz, 1.5).xz / 40;
        gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
    }
	#endif
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    // Transform them into the [0, 1] range
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}
