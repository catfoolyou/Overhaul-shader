#version 120

uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform sampler2D composite;

varying vec2 TexCoords;
uniform float near;
uniform float far;

uniform float viewWidth;
uniform float viewHeight;

float readDepth(vec2 coord) {
     return 2.0 * near * far / (far + near - (2.0 * texture2D(gdepth, coord).x - 1.0) * (far - near));
}

void main(void)
{    
    float depth = readDepth(TexCoords);
    float d;
    
    float pw = 1.0 / viewWidth;
    float ph = 1.0 / viewHeight;
 
    float aoCap = 0.8;
    float ao = 0.0;
    float aoMultiplier = 100.0;
    float depthTolerance = 0.01;
    
    for(int i = 0; i < 5; i++){
        d = readDepth(vec2(TexCoords.x + pw, TexCoords.y + ph));
        ao += min(aoCap, max(0.0, depth - d - depthTolerance) * aoMultiplier);
    }   
 
    for(int i = 0; i < 5; i++){
        pw *= 2.0;
        ph *= 2.0;
        aoMultiplier /= 2.0;
 
        for(int i = 0; i < 5; i++){
            d = readDepth(vec2(TexCoords.x + pw, TexCoords.y + ph));
            ao += min(aoCap, max(0.0, depth - d - depthTolerance) * aoMultiplier);
        }
    }
 
    ao /= 16.0;
    
    gl_FragColor = vec4(1.0 - ao) * texture2D(gcolor, TexCoords);
}

