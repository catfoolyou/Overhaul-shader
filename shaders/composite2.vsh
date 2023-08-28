#version 120

varying vec2 TexCoords;
varying vec2 lmcoord;

uniform sampler2D gcolor;

void main() {
   gl_Position = ftransform();
   TexCoords = gl_MultiTexCoord0.st;
}
