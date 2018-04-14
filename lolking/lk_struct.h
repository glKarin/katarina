#ifndef LK_STRUCT_H
#define LK_STRUCT_H

#include "lk_std.h"
#include "gl/karin_glu.h"
#include "OpenEXR/ImathMatrix.h"

struct Texture
{
	GLuint texid;
	int w;
	int h;
	int channel;
	GLenum format;
	unsigned char* data;
};

struct Frame
{
	float32 pos[3];
	float32 rot[4];
	float32 scale[3];
};

struct AnimationBone
{
	uint32 numFrames;
	int8 *bone;
	uint32 flags;
	Frame *frames;
};

struct Animation
{
	int8 *name;
	int32 fps;
	uint32 numBones;
	AnimationBone *animBones;
	float32 duration;
};

struct Anim
{
    uint32 magic;
    uint32 version;
    uint32 numAnims;
		Animation *animations;
};

struct Material
{
    int8 *name;
    uint32 vStart;
    uint32 vCount;
    uint32 iStart;
    uint32 iCount;
};

struct Vertex
{
    float32 position[3];
    float32 normal[3];
    float32 texture[2];
    uint8 bones[4];
    float32 weights[4];
};

struct Bone
{
	int32 index;
	int8* name;
	int32 parent;
	float32 scale;
	Imath::Matrix44<float> origMatrix; // global matrix
	Imath::Matrix44<float> baseMatrix; // global matrix inverse
	Imath::Matrix44<float> incrMatrix; // local matrix
};

struct MeshBone
{
	uint32 numBones;
	Bone *bones;
};

struct Mesh
{
    uint32 magic;
    uint32 version;
    int8 *animFile;
    int8 *textureFile;
    uint32 numMeshes;
    Material *materials;
    uint32 numVerts;
    Vertex *vertices;
    uint32 numIndices;
    uint16 *indices;
		MeshBone bone;
};

enum ModelFile
{
	MeshFile = 0,
	TextureFile,
	AnimFile
};

#endif // LK_STRUCT_H
