attribute vec3 vPosition;
attribute vec4 vColor;
attribute float vPointSize;

uniform mat4 v_ModelviewProjectionMatrix;

varying vec4 in_Color;

void main()
{
	gl_Position = v_ModelviewProjectionMatrix * vec4(vPosition, 1);
	//gl_Position = vec4(vPosition, 1);
	in_Color = vColor;
	gl_PointSize = vPointSize;
}
