#version 120

uniform sampler2D gcolor;
uniform sampler2D gdepth;
uniform sampler2D gnormal;
uniform sampler2D composite;
 
varying vec4 texcoord;
uniform float aspectRatio;
uniform float near;
uniform float far;
 
uniform float viewWidth;
uniform float viewHeight;
 
float readDepth( vec2 coord );

float readDepth(vec2 coord) {
    return 2.0 * near * far / (far + near - (2.0 * texture2D(gdepth, coord).x - 1.0) * (far - near));
}
 
void main(void)
{   
   float depth = readDepth( texcoord.xy );
   float d;
   
   float pw = 1.0 / viewWidth;
   float ph = 1.0 / viewHeight;
 
   float aoCap = 0.8;
   float ao = 0.0;
   float aoMultiplier=100.0;
   float depthTolerance = 0.01;
   
   d=readDepth( vec2(texcoord.x+pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x+pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
   
   pw*=2.0;
   ph*=2.0;
   aoMultiplier/=2.0;
 
   d=readDepth( vec2(texcoord.x+pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x+pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   pw*=2.0;
   ph*=2.0;
   aoMultiplier/=2.0;
 
   d=readDepth( vec2(texcoord.x+pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x+pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   pw*=2.0;
   ph*=2.0;
   aoMultiplier/=2.0;
 
   d=readDepth( vec2(texcoord.x+pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y+ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x+pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   d=readDepth( vec2(texcoord.x-pw,texcoord.y-ph));
   ao+=min(aoCap,max(0.0,depth-d-depthTolerance) * aoMultiplier);
 
   ao/=16.0;
   
   gl_FragColor = vec4(1.0-ao) * texture2D( gcolor, texcoord.xy );
}
 

