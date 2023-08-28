#version 120

uniform sampler2D gcolor;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;
varying vec2 TexCoords;

// Gaussian blur function
vec3 blur(sampler2D tex, vec2 uv, vec2 resolution, float sigma) {
    vec3 result = vec3(0.0);
    float totalWeight = 0.0;

    for (float x = -4.0 * sigma; x <= 4.0 * sigma; x += 1.0) {
        float weight = exp(-0.5 * x * x / (sigma * sigma));
        result += texture2D(tex, uv + vec2(x, 0.0) / resolution).rgb * weight;
        totalWeight += weight;
    }

    return result / totalWeight;
}

void main() {
    vec3 color = texture2D(gcolor, TexCoords).rgb;
    float Depth = texture2D(depthtex0, TexCoords).r;

    if (Depth == 1.0) {
        gl_FragData[0] = vec4(color, 1.0);
        return;
    }

    // Apply bloom effect
    vec3 blurred = blur(colortex6, TexCoords, vec2(800.0, 600.0), 2.0); // Adjust resolution and sigma as needed

    gl_FragData[0] = vec4(color, 1.0);
}
