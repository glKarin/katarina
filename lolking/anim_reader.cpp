#include "anim_reader.h"
#include "lk_struct.h"
#include "lk_utility.h"
#include "lk_struct.h"
#include <QBuffer>
#include <zlib.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define CHUNK 16384

static void load_animation(QIODevice *in, Anim *anim);
static int inflate(QIODevice* source, QIODevice* dest);

Anim * read_anim(QIODevice *in)
{
	if(!in)
		return NULL;
	in -> open(QIODevice::ReadOnly);
	if(!in -> isOpen())
		return NULL;
	uint32 magic = 0;
	IN_READ(*in, magic);
	if(magic != 604210092)
	{
		in -> close();
		return NULL;
	}
	Anim *anim = (Anim *)malloc(sizeof(Anim));
	memset(anim, 0, sizeof(Anim));

	anim -> magic = magic;
	IN_READ(*in, anim -> version);
	if(anim -> version >= 2)
	{
		QBuffer out;
		out.open(QIODevice::WriteOnly);
		if(!out.isOpen())
		{
			free(anim);
			return NULL;
		}
		inflate(in, &out);
		out.close();
		out.open(QIODevice::ReadOnly);
		if(!out.isOpen())
		{
			free(anim);
			return NULL;
		}
		load_animation(&out, anim);
		out.close();
	}
	else
		load_animation(in, anim);
	in -> close();
	return anim;
}

static void load_animation(QIODevice *in, Anim *anim)
{
	if(!in && !anim)
		return;
	IN_READ(*in, anim -> numAnims);
	anim -> animations = (Animation *)malloc(sizeof(Animation) * anim -> numAnims);
	memset(anim -> animations, 0, sizeof(Animation) * anim -> numAnims);
	for(int i = 0; i < anim -> numAnims; i++)
	{
		Animation *animation = anim -> animations + i;
		animation -> name = get_lower_string(in);
		IN_READ(*in, animation -> fps);
		IN_READ(*in, animation -> numBones);

		animation -> animBones = (AnimationBone *)malloc(sizeof(AnimationBone) * animation -> numBones);
		memset(animation -> animBones, 0, sizeof(AnimationBone) * animation -> numBones);

		for(int j = 0; j < animation -> numBones; j++)
		{
			AnimationBone *animBone = animation -> animBones + j;
			IN_READ(*in, animBone -> numFrames);
			animBone -> bone = get_lower_string(in);
			IN_READ(*in, animBone -> flags);
			animBone -> frames = (Frame *)malloc(sizeof(Frame) * animBone -> numFrames);
			memset(animBone -> frames, 0, sizeof(Frame) * animBone -> numFrames);
			if(anim -> version >= 3)
				IN_READ_ARR(*in, animBone -> frames[0], animBone -> numFrames);
			else
			{
				for(int k = 0; k < animBone -> numFrames; k++)
				{
					IN_READ_ARR(*in, animBone -> frames[k].pos[0], 3);
					IN_READ_ARR(*in, animBone -> frames[k].rot[0], 4);
					animBone -> frames[k].scale[0] = 
					animBone -> frames[k].scale[1] = 
					animBone -> frames[k].scale[2] = 1.0f;
				}
			}
		}

		if(animation -> numBones == 0 || animation -> fps <= 1)
			animation -> duration = 1e3;
		else
			animation -> duration = floor(1e3 * (animation -> animBones[0].numFrames / animation -> fps));
	}
}

void free_anim(Anim *anim)
{
	if(!anim)
		return;
	for(int i = 0; i < anim -> numAnims; i++)
	{
		Animation *animation = anim -> animations + i;
		free(animation -> name);
		for(int j = 0; j < animation -> numBones; j++)
		{
			free(animation -> animBones[j].bone);
			free(animation -> animBones[j].frames);
		}
		free(animation -> animBones);
	}
	free(anim -> animations);
	free(anim);
}

static int inflate(QIODevice* source, QIODevice* dest)
{
	int ret;
	unsigned have;
	z_stream strm;
	unsigned char in[CHUNK];
	unsigned char out[CHUNK];

	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.avail_in = 0;
	strm.next_in = Z_NULL;
	ret = inflateInit(&strm);
	if (ret != Z_OK)
		return ret;
	do
	{
		strm.avail_in = IN_READ_ARR(*source, in[0], CHUNK);
		//strm.avail_in = fread(in,1,CHUNK,source);
		/*
		if (ferror(source))
		{
			(void)inflateEnd(&strm);
			return Z_ERRNO;
		}
		*/
		if(source -> atEnd())
			break;
		if (0 == strm.avail_in)
			break;
		strm.next_in = in;
		do
		{
			strm.avail_out = CHUNK;
			strm.next_out = out;

			ret = inflate(&strm, Z_NO_FLUSH);
			switch(ret)
			{
				case Z_NEED_DICT:
					ret = Z_DATA_ERROR;
				case Z_DATA_ERROR:
				case Z_MEM_ERROR:
					(void)inflateEnd(&strm);
					return ret;
			}
			have = CHUNK - strm.avail_out;
			//if (fwrite(out,1,have,dest) != have || ferror(dest))
			if (dest -> write((char *)out, have) != have)
			{
				(void)inflateEnd(&strm);
				return Z_ERRNO;
			}
		}while (strm.avail_out == 0);
	}while(ret != Z_STREAM_END);
	(void)inflateEnd(&strm);
	return ret = Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
}

