attribute vec3 vPosition;
attribute vec2 vTexcoord;

uniform mat4 v_ModelviewProjectionMatrix;

varying vec2 in_Texcoord;

void main()
{
	gl_Position = v_ModelviewProjectionMatrix * vec4(vPosition, 1);
	//gl_Position = vec4(vPosition, 1);
	in_Texcoord = vTexcoord;
}
