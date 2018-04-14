#include "g_gui.h"

#include <math.h>
#include "gutility.h"
#include "OpenEXR/ImathVec.h"

using Imath::Vec3;

GLuint load_button(GLfloat width, GLfloat height, const GLfloat releaseTexcoord[], const GLfloat pressTexcoord[])
{
		GLfloat position[] = {
			0.0f, 0.0f, 0.0f,
			releaseTexcoord[0], releaseTexcoord[1],
			pressTexcoord[0], pressTexcoord[1],
			width, 0.0f, 0.0f,
			releaseTexcoord[2], releaseTexcoord[3],
			pressTexcoord[2], pressTexcoord[3],
			0.0f, height, 0.0f,
			releaseTexcoord[4], releaseTexcoord[5],
			pressTexcoord[4], pressTexcoord[5],
			width, height, 0.0f,
			releaseTexcoord[6], releaseTexcoord[7],
			pressTexcoord[6], pressTexcoord[7]
		};
		return glkLoadBuffer(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(GLfloat) * 28, (GLvoid *)position);
}

void draw_button(GLuint buffer, GLint *attributes, const Matrix44<GLfloat> *matrixs, GLfloat x, GLfloat y, GLboolean pressed, GLfloat angle)
{
	Matrix44<GLfloat> matrix;
	matrix.makeIdentity();
	Matrix44<GLfloat> translationMatrix;
	Matrix44<GLfloat> rotationMatrix;
	Vec3<GLfloat> translation(x, y, 0.0f);
	translationMatrix.translate(translation);
	Vec3<GLfloat> zRotation(0.0f, 0.0f, 1.0f);
	rotationMatrix.setAxisAngle(zRotation, (GLfloat)KARIN_ANGLE_TO_RADIAN(angle));

	matrix = matrixs[0] * rotationMatrix * translationMatrix;
	Matrix44<GLfloat> modelviewProjectionMatrix = matrix * matrixs[1];
	glUniformMatrix4fv(attributes[2], 1, GL_FALSE, (GLfloat *)modelviewProjectionMatrix.x);

	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 7, (GLvoid *)0);
	GLuint start = pressed ? 5 : 3;
	glVertexAttribPointer(attributes[1], 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 7, (GLvoid *)(sizeof(GLfloat) * start));
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}
