#include "lk_struct.h"
#include "lk_utility.h"
#include "mesh_reader.h"
#include "imath_ext.h"
#include <QIODevice>
#include <QMap>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void free_mesh(Mesh *mesh)
{
	if(!mesh)
		return;
	free(mesh -> animFile);
	free(mesh -> textureFile);
	for(int i = 0; i < mesh -> numMeshes; i++)
		free(mesh -> materials[i].name);
	free(mesh -> materials);
	free(mesh -> vertices);
	free(mesh -> indices);
	for(int i = 0; i < mesh -> bone.numBones; i++)
		free(mesh -> bone.bones[i].name);
	free(mesh -> bone.bones);

	free(mesh);
}

Mesh * read_mesh(QIODevice *in)
{
	if(!in)
		return NULL;
	in -> open(QIODevice::ReadOnly);
	if(!in -> isOpen())
		return NULL;
	uint32 magic = 0;
	IN_READ(*in, magic);
	if(magic != 604210091)
	{
		in -> close();
		return NULL;
	}
	Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
	memset(mesh, 0, sizeof(Mesh));
	mesh -> magic = magic;
	IN_READ(*in, mesh -> version);

	mesh -> animFile = get_string(in);
	mesh -> textureFile = get_string(in);

	IN_READ(*in, mesh -> numMeshes);
	mesh -> materials = (Material *)malloc(mesh -> numMeshes * sizeof(Material));
	memset(mesh -> materials, 0, sizeof(Material) * mesh -> numMeshes);
	for(int i = 0; i < mesh -> numMeshes; i++)
	{
		mesh -> materials[i].name = get_string(in);
		IN_READ(*in, mesh -> materials[i].vStart);
		IN_READ(*in, mesh -> materials[i].vCount);
		IN_READ(*in, mesh -> materials[i].iStart);
		IN_READ(*in, mesh -> materials[i].iCount);
	}

	IN_READ(*in, mesh -> numVerts);
	mesh -> vertices = (Vertex *)malloc(mesh -> numVerts * sizeof(Vertex));
	memset(mesh -> vertices, 0, mesh -> numVerts * sizeof(Vertex));
	IN_READ_ARR(*in, mesh -> vertices[0], mesh -> numVerts);

	IN_READ(*in, mesh -> numIndices);
	mesh -> indices = (uint16 *)malloc(mesh -> numIndices * sizeof(uint16));
	memset(mesh -> indices, 0, sizeof(uint16) * mesh -> numIndices);
	IN_READ_ARR(*in, mesh -> indices[0], mesh -> numIndices);

	/*
		 for(int i = 0; i < mesh -> numVerts; i++)
		 cout<<mesh->vertices[i].texture[0]<<" "<<mesh->vertices[i].texture[1]<<endl;
		 */

	MeshBone *meshBone = &(mesh -> bone);
	IN_READ(*in, meshBone -> numBones);
	meshBone -> bones = (Bone *)malloc(sizeof(Bone) * meshBone -> numBones);
	memset(meshBone -> bones, 0, sizeof(Bone) * meshBone -> numBones);
	for(int i = 0; i < meshBone -> numBones; i++)
	{
		Bone *bone = meshBone -> bones + i;
		bone -> index = i;
		bone -> name = get_lower_string(in);
		IN_READ(*in, bone -> parent);
		IN_READ(*in, bone -> scale);
		bone -> origMatrix.makeIdentity();
		IN_READ_ARR(*in, ((float32 *)bone -> origMatrix.x)[0], 16);

		bone -> baseMatrix = bone -> origMatrix;
		bone -> baseMatrix = g_transpose_matrix(bone -> baseMatrix);
		bone -> baseMatrix = bone -> baseMatrix.gjInverse();
		bone -> origMatrix = g_transpose_matrix(bone -> origMatrix);
		bone -> incrMatrix.makeIdentity();
		if(mesh -> version >= 2)
		{
			IN_READ_ARR(*in, ((float32 *)bone -> incrMatrix.x)[0], 16);
			bone -> incrMatrix = g_transpose_matrix(bone -> incrMatrix);
		}

	}
	QMap<QString, int32> boneLookup;
	for(int i = 0; i < meshBone -> numBones; i++)
	{
		if(boneLookup.contains(QString(meshBone -> bones[i].name)))
		{
			size_t len = strlen(meshBone -> bones[i].name);
			int8 *new_name = (int8 *)malloc(len + 1 + 1);
			strcpy(new_name, meshBone -> bones[i].name);
			new_name[len] = '2';
			new_name[len + 1] = '\0';
			free(meshBone -> bones[i].name);
			meshBone -> bones[i].name = new_name;
		}
		boneLookup.insert(QString(meshBone -> bones[i].name), i);
	}

	in -> close();
	return mesh;
}

