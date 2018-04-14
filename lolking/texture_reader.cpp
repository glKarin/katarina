#include "SOIL.h"
#include "lk_struct.h"
#include "texture_reader.h"
#include <QIODevice>
#include <QByteArray>
#include <stdlib.h>
#include <stdio.h>

Texture * read_texture(QIODevice *in)
{
	if(!in)
		return NULL;
	in -> open(QIODevice::ReadOnly);
	if(!in -> isOpen())
		return NULL;
	QByteArray bytes = in -> readAll();
	const char *dds = bytes.data();
	Texture *g_tex = (Texture *)malloc(sizeof(Texture));
	g_tex -> data = SOIL_load_image_from_memory((const unsigned char *)dds, bytes.size(), &g_tex -> w, &g_tex -> h, &g_tex -> channel, SOIL_LOAD_AUTO);
	if(g_tex -> data == NULL)
	{
		fprintf(stderr, "Unable load texture.\n");
		free(g_tex);
		return NULL;
	}

	g_tex -> format = 0;
	switch(g_tex -> channel)
	{
		case SOIL_LOAD_L:
			g_tex -> format = GL_LUMINANCE;
			break;
		case SOIL_LOAD_LA:
			g_tex -> format = GL_LUMINANCE_ALPHA;
			break;
		case SOIL_LOAD_RGB:
			g_tex -> format = GL_RGB;
			break;
		case SOIL_LOAD_RGBA:
			g_tex -> format = GL_RGBA;
			break;
		default:
			break;
	}
	if(g_tex -> format != 0)
	{
		// SOIL_load_OGL_texture()
		glGenTextures(1, &(g_tex -> texid));
		glBindTexture(GL_TEXTURE_2D, g_tex -> texid);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);	
		glTexImage2D(GL_TEXTURE_2D, 0, g_tex -> format, g_tex -> w, g_tex -> h, 0, g_tex -> format, GL_UNSIGNED_BYTE, g_tex -> data);

		glBindTexture(GL_TEXTURE_2D, 0);

		free(g_tex -> data);
		g_tex -> data = NULL;

		printf("texture %d: width -> %d, height -> %d, channel -> %d(%s)\n", g_tex -> texid, g_tex -> w, g_tex -> h, g_tex -> channel, 
				(g_tex -> channel == 1 ? "luminance" : (g_tex -> channel == 2 ? "luminance-alpha" : (g_tex -> channel == 3 ? "RGB" : "RGBA"))));
		return g_tex;
	}
	else
	{
		fprintf(stderr, "Unsupport format of this texture.\n");
		free(g_tex -> data);
		free(g_tex);
		return NULL;
	}
	in -> close();
}

void free_texture(Texture *tex)
{
	if(!tex)
		return;
	if(tex -> data)
		free(tex);
	free(tex);
}

Texture * read_texture_from_file(const char *dds)
{
	if(!dds)
		return NULL;
	Texture *g_tex = (Texture *)malloc(sizeof(Texture));
	g_tex -> data = SOIL_load_image(dds, &g_tex -> w, &g_tex -> h, &g_tex -> channel, SOIL_LOAD_AUTO);
	if(g_tex -> data == NULL)
	{
		fprintf(stderr, "Unable load texture file.\n");
		free(g_tex);
		return NULL;
	}

	g_tex -> format = 0;
	switch(g_tex -> channel)
	{
		case SOIL_LOAD_L:
			g_tex -> format = GL_LUMINANCE;
			break;
		case SOIL_LOAD_LA:
			g_tex -> format = GL_LUMINANCE_ALPHA;
			break;
		case SOIL_LOAD_RGB:
			g_tex -> format = GL_RGB;
			break;
		case SOIL_LOAD_RGBA:
			g_tex -> format = GL_RGBA;
			break;
		default:
			break;
	}
	if(g_tex -> format != 0)
	{
		// SOIL_load_OGL_texture()
		glGenTextures(1, &(g_tex -> texid));
		glBindTexture(GL_TEXTURE_2D, g_tex -> texid);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);	
		glTexImage2D(GL_TEXTURE_2D, 0, g_tex -> format, g_tex -> w, g_tex -> h, 0, g_tex -> format, GL_UNSIGNED_BYTE, g_tex -> data);

		glBindTexture(GL_TEXTURE_2D, 0);

		free(g_tex -> data);
		g_tex -> data = NULL;

		printf("texture %d: width -> %d, height -> %d, channel -> %d(%s)\n", g_tex -> texid, g_tex -> w, g_tex -> h, g_tex -> channel, 
				(g_tex -> channel == 1 ? "luminance" : (g_tex -> channel == 2 ? "luminance-alpha" : (g_tex -> channel == 3 ? "RGB" : "RGBA"))));
		return g_tex;
	}
	else
	{
		fprintf(stderr, "Unsupport format of this texture file.\n");
		free(g_tex -> data);
		free(g_tex);
		return NULL;
	}
}
