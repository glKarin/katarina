#ifndef _G_GUI_H
#define _G_GUI_H

#include "lk_struct.h"
#include "OpenEXR/ImathMatrix.h"

using Imath::Matrix44;

GLuint load_button(GLfloat width, GLfloat height, const GLfloat releaseTexcoord[], const GLfloat pressTexcoord[]);
void draw_button(GLuint buffer, GLint *attributes, const Matrix44<GLfloat> *matrixs, GLfloat x, GLfloat y, GLboolean pressed, GLfloat angle);
#endif
