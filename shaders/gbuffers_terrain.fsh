#version 120

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
varying float id;

// The texture atlas
uniform sampler2D texture;
uniform sampler2D normals;      
uniform sampler2D specular;

void main(){
	vec4 Albedo = texture2D(texture, TexCoords) * Color;
	//vec4 Specular = texture2D(specular, TexCoords);
	//vec4 Normalmaps = texture2D(normals, TexCoords);
    /* DRAWBUFFERS:012 */
    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}
