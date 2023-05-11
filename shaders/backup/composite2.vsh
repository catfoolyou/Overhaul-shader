#version 120

varying vec2 TexCoords;
varying vec2 lmcoord;

void main() {
   gl_Position = ftransform();
   TexCoords = gl_MultiTexCoord0.st;
}
