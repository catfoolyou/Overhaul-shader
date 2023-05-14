#version 120

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

// The texture atlas
uniform sampler2D texture;
uniform vec4 entityColor;

void main(){
    vec4 Albedo = texture2D(texture, TexCoords) * Color;
    Albedo.rgb = mix(Albedo.rgb, entityColor.rgb, entityColor.a);
    /* DRAWBUFFERS:012 */
    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords / 1.3, 0.0f, 1.0f);
}
