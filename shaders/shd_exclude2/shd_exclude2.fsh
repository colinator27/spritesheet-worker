//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 excludeColor1;
uniform vec4 excludeColor2;

void main()
{
	vec4 texColor = texture2D(gm_BaseTexture, v_vTexcoord);
	if (texColor == excludeColor1 || texColor == excludeColor2)
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	else
		gl_FragColor = texColor;
}
