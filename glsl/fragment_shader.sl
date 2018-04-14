precision mediump float;

varying vec2 in_Texcoord;

uniform sampler2D fTexture;
uniform bool fHasTexture;

void main()
{
	if(fHasTexture)
		gl_FragColor = texture2D(fTexture, in_Texcoord);
	else
		gl_FragColor = vec4(1.0, 0.5, 1.0, 1.0);
}

