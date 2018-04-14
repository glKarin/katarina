#ifndef _KARIN_GLU_H
#define _KARIN_GLU_H

#include <GLES2/gl2.h>

GLuint glkLoadBuffer(GLenum buffer, GLenum drawType, GLsizei size, const GLvoid *data);

void glkGetShaderLog(GLuint shader, char *log);

void glkGetProgramLog(GLuint programObject, char *log);

GLuint glkLoadShader(GLenum type, const char *shaderSrc);

char * glkLoadShaderSource(const char *file);

void glkOrtho(GLfloat m[], GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat nearval, GLfloat farval);
void glkOrtho2D(GLfloat m[], GLfloat left, GLfloat right, GLfloat bottom, GLfloat top);
void glkPerspective(GLfloat m[], GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);

const char * glkGetError();

#endif
