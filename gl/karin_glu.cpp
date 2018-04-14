#include "karin_glu.h"

#include <iostream>
#include <fstream>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

using namespace std;
static const char *GLErrorString[] = {
	"GL_NO_ERROR",
	"GL_INVALID_ENUM",
	"GL_INVALID_VALUE",
	"GL_INVALID_OPERATION",
	"GL_OUT_OF_MEMORY"
};

void glkGetShaderLog(GLuint shader, char *log)
{
	GLint infoLen = 0;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
	if (infoLen > 1)
	{
		char* infoLog = (char *)malloc (sizeof(char) * infoLen );
		memset(infoLog, 0, sizeof(char) * infoLen);
		glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
		fprintf(stderr, "Error compiling shader:\n%s\n", infoLog);
		if(log)
			log = infoLog;
		else
			free(infoLog);
	}
}

void glkGetProgramLog(GLuint programObject, char *log)
{
	GLint infoLen = 0;
	glGetProgramiv(programObject, GL_INFO_LOG_LENGTH, &infoLen);
	if(infoLen > 1)
	{
		char* infoLog = (char*)malloc (sizeof(char) * infoLen );
		memset(infoLog, 0, sizeof(char) * infoLen);
		glGetProgramInfoLog(programObject, infoLen, NULL, infoLog );
		fprintf(stderr, "Error linking program:\n%s\n", infoLog);
		if(log)
			log = infoLog;
		else
			free(infoLog);
	}
}

GLuint glkLoadShader(GLenum type, const char *shaderSrc)
{
	GLuint shader;
	GLint compiled;
	//Create the shader object
	shader = glCreateShader(type);
	if (shader == 0)
		return 0;
	//Load the shader source
	glShaderSource (shader, 1, &shaderSrc, NULL);
	//Compile the shader
	glCompileShader(shader);
	//Check the compile status
	glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
	if (!compiled)
	{
		glkGetShaderLog(shader, NULL);
		glDeleteShader(shader);
		return 0;
	}
	return shader;
}

char * glkLoadShaderSource(const char *file)
{
	if(!file)
		return 0;
	ifstream in(file, ios::in);
	if(!in.is_open())
	{
		cerr<<"Unable to open shader file -> "<<file<<endl;
	}
	string str;
	while(in.peek() != EOF)
		str += in.get();
	in.close();
	char *src = (char *)malloc(sizeof(char) * str.size() + 1);
	memset(src, 0, sizeof(char) * str.size() + 1);
	src[str.size()] = '\0';
	strncpy(src, str.data(),str.size());
	/*
	int i;
	for(i = 0; i < str.size(); i++)
		src[i] = str.at(i);
		*/
	return src;
}

GLuint glkLoadBuffer(GLenum buffer, GLenum drawType, GLsizei size, const GLvoid *data)
{
	GLuint id = 0;
	glGenBuffers(1, &id);
	glBindBuffer(buffer, id);
	glBufferData(buffer, size, data, drawType);
	glBindBuffer(buffer, 0);
	return id;
}

void glkOrtho(GLfloat m[], GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat nearval, GLfloat farval)
{
   //GLfloat m[16];

#define M(row,col)  m[col*4+row]
   M(0,0) = 2.0F / (right-left);
   M(0,1) = 0.0F;
   M(0,2) = 0.0F;
   M(0,3) = -(right+left) / (right-left);

   M(1,0) = 0.0F;
   M(1,1) = 2.0F / (top-bottom);
   M(1,2) = 0.0F;
   M(1,3) = -(top+bottom) / (top-bottom);

   M(2,0) = 0.0F;
   M(2,1) = 0.0F;
   M(2,2) = -2.0F / (farval-nearval);
   M(2,3) = -(farval+nearval) / (farval-nearval);

   M(3,0) = 0.0F;
   M(3,1) = 0.0F;
   M(3,2) = 0.0F;
   M(3,3) = 1.0F;
#undef M

   //matrix_multf( mat, m, (MAT_FLAG_GENERAL_SCALE|MAT_FLAG_TRANSLATION));
}

void glkOrtho2D(GLfloat m[], GLfloat left, GLfloat right, GLfloat bottom, GLfloat top)
{
	glkOrtho(m, left, right, bottom, top, -1.0, 1.0);
}

static void frustum(GLfloat m[], GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat nearval, GLfloat farval)
{
   GLfloat x, y, a, b, c, d;

   x = (2.0 * nearval) / (right - left);
   y = (2.0 * nearval) / (top - bottom);
   a = (right + left) / (right - left);
   b = (top + bottom) / (top - bottom);
   c = -(farval + nearval) / ( farval - nearval);
   d = -(2.0 * farval * nearval) / (farval - nearval);

#define M(row,col)  m[col*4+row]
   M(0,0) = x;     M(0,1) = 0.0F;  M(0,2) = a;      M(0,3) = 0.0F;
   M(1,0) = 0.0F;  M(1,1) = y;     M(1,2) = b;      M(1,3) = 0.0F;
   M(2,0) = 0.0F;  M(2,1) = 0.0F;  M(2,2) = c;      M(2,3) = d;
   M(3,0) = 0.0F;  M(3,1) = 0.0F;  M(3,2) = -1.0F;  M(3,3) = 0.0F;
#undef M

   //glMultMatrixd(m);
}


void glkPerspective(GLfloat m[], GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
   GLfloat xmin, xmax, ymin, ymax;

   ymax = zNear * tan(fovy * M_PI / 360.0);
   ymin = -ymax;
   xmin = ymin * aspect;
   xmax = ymax * aspect;

   /* don't call glFrustum() because of error semantics (covglu) */
   frustum(m, xmin, xmax, ymin, ymax, zNear, zFar);
}

const char * glkGetError()
{
	GLenum error;
	GLuint i = 0;
	while((error = glGetError()) != GL_NO_ERROR)
	{
		switch(error)
		{
			case GL_INVALID_ENUM:
				i = 1;
				break;
			case GL_INVALID_VALUE:
				i = 2;
				break;
			case GL_INVALID_OPERATION:
				i = 3;
				break;
			case GL_OUT_OF_MEMORY:
				i = 4;
				break;
			case GL_NO_ERROR:
			default:
				i = 0;
				break;
		}
		fprintf(stderr, "OpenGL error -> %s\n", GLErrorString[i]);
	}
	if(i == 0)
		printf("%d\n", GLErrorString[i]);
	return GLErrorString[i];
}
