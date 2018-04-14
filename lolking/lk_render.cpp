#include "lk_render.h"
#include "imath_ext.h"
#include <stdlib.h>
#include <QDebug>
#include <string.h>
#include <OpenEXR/ImathVec.h>
#include <OpenEXR/ImathMatrix.h>

using Imath::Vec3;
using Imath::Matrix44;

static Vertex * updateVertex(const Mesh *mesh)
{
	if(!mesh)
		return NULL;
	const MeshBone *skl = &(mesh -> bone);
	Vertex *verteces = (Vertex *)malloc(sizeof(Vertex) * mesh -> numVerts);
	memcpy(verteces, mesh -> vertices, sizeof(Vertex) * mesh -> numVerts);

	for(int i = 0; i < mesh -> numVerts; i++)
	{
		Vertex *vertex = verteces + i;
		const Vec3<float> v(vertex -> position[0], vertex -> position[1], vertex -> position[2]);
		const Vec3<float> n(vertex -> normal[0], vertex -> normal[1], vertex -> normal[2]);
		Vec3<float> nv(0.0);
		Vec3<float> nn(0.0);
		unsigned int j;
		for(j = 0; j < sizeof(vertex -> bones) / sizeof(uint8); j++)
		{
			if(vertex -> weights[j] == 0.0) continue;
			uint32 idx = vertex -> bones[j];
			if(idx < skl -> numBones)
				idx = skl -> bones[idx].index;
			/*
				 if(idx >= skl -> numBones)
				 continue;
				 */

			Matrix44<float> mat = skl -> bones[idx].baseMatrix;
			Matrix44<float> mat2 = skl -> bones[idx].origMatrix;
			nv += (v * (mat * mat2) * vertex -> weights[j]);
			nn += (n * (mat * mat2) * vertex -> weights[j]);
		}
		vertex -> position[0] = nv.x;
		vertex -> position[1] = nv.y;
		vertex -> position[2] = nv.z;
		vertex -> normal[0] = nn.x;
		vertex -> normal[1] = nn.y;
		vertex -> normal[2] = nn.z;
	}
	return verteces;
}

static void updateBoneVertex(const MeshBone *skl, GLfloat **bonePoints, GLuint *pointCount, GLfloat **boneLines, GLuint *lineCount)
{
	if(!skl)
		return;

	const Bone *bones = skl -> bones;
	*bonePoints = (GLfloat *)malloc(skl -> numBones * 3 * sizeof(GLfloat));
	memset(*bonePoints, 0, sizeof(GLfloat) * skl -> numBones * 3);
	for(int i = 0; i < skl -> numBones; i++)
	{
		Vec3<float> v(1.0f, 1.0f, 1.0f);
		Matrix44<float> tm = skl -> bones[i].origMatrix;
		v = v * tm;
		(*bonePoints)[i * 3 + 0] = v.x;
		(*bonePoints)[i * 3 + 1] = v.y;
		(*bonePoints)[i * 3 + 2] = v.z;
	}
	if(pointCount)
		*pointCount = skl -> numBones;

	size_t size = 0;
	for(int i = 0; i < skl -> numBones; i++)
	{
		for(int j = 0; j < skl -> numBones; j++)
		{
			if(bones[j].parent == i)
				size++;
		}
	}

	*boneLines = (GLfloat *)malloc(size * 2 * 3 * sizeof(GLfloat));
	memset(*boneLines, 0, sizeof(GLfloat) * size * 2 * 3);
	int c = 0;
	for(int i = 0; i < skl -> numBones; i++)
	{
		for(int j = 0; j < skl -> numBones; j++)
		{
			if(bones[j].parent == i)
			{
				(*boneLines)[c * 6 + 0] = (*bonePoints)[i * 3 + 0];
				(*boneLines)[c * 6 + 1] = (*bonePoints)[i * 3 + 1];
				(*boneLines)[c * 6 + 2] = (*bonePoints)[i * 3 + 2];
				(*boneLines)[c * 6 + 3] = (*bonePoints)[j * 3 + 0];
				(*boneLines)[c * 6 + 4] = (*bonePoints)[j * 3 + 1];
				(*boneLines)[c * 6 + 5] = (*bonePoints)[j * 3 + 2];
				c++;
			}
		}
	}
	if(lineCount)
		*lineCount = size * 2;
}

void updateBone(MeshBone *skl, const Animation *anm, int frame)
{
	if(!skl || !anm)
	{
		return;
	}
	int i;
	for(i = 0; i < skl -> numBones; i++)
	{
		int j;
		bool hasBone = false;
		for(j = 0; j < anm -> numBones; j++)
			if(strcmp(skl -> bones[i].name, anm -> animBones[j].bone) == 0)
			{
				hasBone = true;
				break;
			}
		if(!hasBone)
			continue;
		Bone *bone = skl -> bones + i;
		const Frame *a = anm -> animBones[j].frames + frame;
		if(bone -> parent == -1)
		{
			bone -> incrMatrix = g_quat_to_matrix(a -> rot, a -> pos, a -> scale);
			bone -> origMatrix = bone -> incrMatrix;
		}
		else
		{
			const Bone *pBone = skl -> bones + bone -> parent;
			bone -> incrMatrix = g_quat_to_matrix(a -> rot, a -> pos, a -> scale);
			bone -> origMatrix =  bone -> incrMatrix * pBone -> origMatrix;
		}
	}
}

/* *** used buffer *** */

void drawSknBUFFER(const Mesh *mesh, const GLuint buffers[], const GLint attributes[], const Texture *tex)
{
	if(!mesh || !buffers || !attributes)
	{
		return;
	}

	if(!glIsBuffer(buffers[0]) || !glIsBuffer(buffers[1]))
		return;

		glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
		glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)0);
		glVertexAttribPointer(attributes[1], 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(GLfloat) * 6));

	glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE0);

	int i;
	for(i = 0; i < mesh -> numMeshes; i++)
	{
		if(tex && glIsTexture(tex -> texid))
		{
			glBindTexture(GL_TEXTURE_2D, tex -> texid);
		}
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffers[1]);
		glDrawElements(GL_TRIANGLES, mesh -> materials[i].iCount, GL_UNSIGNED_SHORT, (GLvoid *)(sizeof(GLushort) * mesh -> materials[i].iStart));
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		if(tex && glIsTexture(tex -> texid))
			glBindTexture(GL_TEXTURE_2D,0);
	}

	glDisable(GL_TEXTURE_2D);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void drawBoneBUFFER(const GLuint buffers[], const GLuint count[], const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[])
{
	if(!buffers || !attributes || !count || !color || !sizes)
	{
		return;
	}
	if(!glIsBuffer(buffers[0]) || !glIsBuffer(buffers[1]))
		return;

	GLfloat lineWidth;
	glGetFloatv(GL_LINE_WIDTH, &lineWidth);

	{
		glBindBuffer(GL_ARRAY_BUFFER, buffers[1]);
		glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, 0, (GLvoid *)0);
		glVertexAttrib4fv(attributes[1], color[1]);
		glLineWidth(sizes[1]);
		glDrawArrays(GL_LINES, 0, count[1]);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	{
		glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
		glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, 0, (GLvoid *)0);
		glVertexAttrib4fv(attributes[1], color[0]);
		glVertexAttrib1f(attributes[2], sizes[0]);
		glDrawArrays(GL_POINTS, 0, count[0]);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	glLineWidth(lineWidth);
}

void drawAnmSknBUFFER(const Mesh *mesh, const GLuint buffers[], const GLint attributes[], const Texture *tex)
{
	if(!mesh || !buffers || !attributes)
	{
		return;
	}
	if(!glIsBuffer(buffers[0]) || !glIsBuffer(buffers[1]))
		return;

	const MeshBone *skl = &(mesh -> bone);
	Vertex *verteces = updateVertex(mesh);

	glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * mesh -> numVerts, verteces, GL_DYNAMIC_DRAW);
	glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)0);
	glVertexAttribPointer(attributes[1], 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(GLfloat) * 6));

	glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE0);

	int i;
	for(i = 0; i < mesh -> numMeshes; i++)
	{
		if(tex && glIsTexture(tex -> texid))
		{
			glBindTexture(GL_TEXTURE_2D, tex -> texid);
		}
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffers[1]);
		glDrawElements(GL_TRIANGLES, mesh -> materials[i].iCount, GL_UNSIGNED_SHORT, (GLvoid *)(sizeof(GLushort) * mesh -> materials[i].iStart));
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		if(tex && glIsTexture(tex -> texid))
			glBindTexture(GL_TEXTURE_2D,0);
	}

	glDisable(GL_TEXTURE_2D);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	free(verteces);
}

void drawAnimationBoneBUFFER(const MeshBone *skl, const GLuint buffers[], const GLuint count[], const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[])
{
	if(!skl || !buffers || !attributes || !count || !color || !sizes)
	{
		return;
	}
	if(!glIsBuffer(buffers[0]) || !glIsBuffer(buffers[1]))
		return;

	GLfloat *bonePoints = NULL;
	GLfloat *boneLines = NULL;
	GLuint pointCount;
	GLuint lineCount;
	updateBoneVertex(skl, &bonePoints, &pointCount, &boneLines, &lineCount);

	GLfloat lineWidth;
	glGetFloatv(GL_LINE_WIDTH, &lineWidth);

	{
		glBindBuffer(GL_ARRAY_BUFFER, buffers[1]);
		glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 3 * lineCount, boneLines, GL_DYNAMIC_DRAW);
		glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, 0, (GLvoid *)0);
		glVertexAttrib4fv(attributes[1], color[1]);
		glLineWidth(sizes[1]);
		glDrawArrays(GL_LINES, 0, count[1]);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	{
		glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
		glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 3 * pointCount, bonePoints, GL_DYNAMIC_DRAW);
		glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, 0, (GLvoid *)0);
		glVertexAttrib4fv(attributes[1], color[0]);
		glVertexAttrib1f(attributes[2], sizes[0]);
		glDrawArrays(GL_POINTS, 0, count[0]);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}
	glLineWidth(lineWidth);
}

/* *** unused buffer *** */

void drawSkn(const Mesh *mesh, const GLint attributes[], const Texture *tex)
{
	if(!mesh || !attributes)
	{
		return;
	}

	glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)mesh -> vertices);
	glVertexAttribPointer(attributes[1], 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)&(mesh-> vertices[0].texture[0]));

	glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE0);

	int i;
	for(i = 0; i < mesh -> numMeshes; i++)
	{
		if(tex && glIsTexture(tex -> texid))
		{
			glBindTexture(GL_TEXTURE_2D, tex -> texid);
		}
		glDrawElements(GL_TRIANGLES, mesh -> materials[i].iCount, GL_UNSIGNED_SHORT, mesh -> indices + mesh -> materials[i].iStart);
		if(tex && glIsTexture(tex -> texid))
			glBindTexture(GL_TEXTURE_2D,0);
	}

	glDisable(GL_TEXTURE_2D);
}

void drawBone(const MeshBone *skl, const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[])
{
	if(!skl || !attributes || !color || !sizes)
	{
		return;
	}

	GLfloat lineWidth;
	glGetFloatv(GL_LINE_WIDTH, &lineWidth);

	GLfloat *bonePoints = NULL;
	GLfloat *boneLines = NULL;
	GLuint pointCount;
	GLuint lineCount;
	updateBoneVertex(skl, &bonePoints, &pointCount, &boneLines, &lineCount);

	{
		glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, 0, (GLvoid *)boneLines);
		glVertexAttrib4fv(attributes[1], color[1]);
		glLineWidth(sizes[1]);
		glDrawArrays(GL_LINES, 0, lineCount);
	}
	{
		glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, 0, (GLvoid *)bonePoints);
		glVertexAttrib4fv(attributes[1], color[0]);
		glVertexAttrib1f(attributes[2], sizes[0]);
		glDrawArrays(GL_POINTS, 0, pointCount);
	}
	free(boneLines);
	free(bonePoints);
	glLineWidth(lineWidth);
}

void drawAnmSkn(const Mesh *mesh, const GLint attributes[], const Texture *tex)
{
	if(!mesh || !attributes)
	{
		return;
	}

	Vertex *verteces = updateVertex(mesh);

	glVertexAttribPointer(attributes[0], 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)verteces);
	glVertexAttribPointer(attributes[1], 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)&(verteces[0].texture[0]));

	glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE0);

	int i;
	for(i = 0; i < mesh -> numMeshes; i++)
	{
		if(tex && glIsTexture(tex -> texid))
		{
			glBindTexture(GL_TEXTURE_2D, tex -> texid);
		}
		glDrawElements(GL_TRIANGLES, mesh -> materials[i].iCount, GL_UNSIGNED_SHORT, mesh -> indices + mesh -> materials[i].iStart);
		if(tex && glIsTexture(tex -> texid))
			glBindTexture(GL_TEXTURE_2D,0);
	}

	glDisable(GL_TEXTURE_2D);

	free(verteces);
}

void drawAnimationBone(const MeshBone *skl, const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[])
{
	drawBone(skl, attributes, color, sizes);
}

