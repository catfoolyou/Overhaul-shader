#version 120

varying vec2 TexCoords;
varying vec2 lmcoord;
varying float isNight;

uniform int worldTime;

void main() {
   gl_Position = ftransform();
   TexCoords = gl_MultiTexCoord0.st;

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
}
