#version 120

varying vec2 TexCoords;
varying vec4 Color;

vec2 DistortPosition(in vec2 position){
    return position / mix(1.0f, length(position), 0.9f);
}

void main(){
    gl_Position = ftransform();
    gl_Position.xy = DistortPosition(gl_Position.xy);
    TexCoords = gl_MultiTexCoord0.st;
    Color = gl_Color;
}