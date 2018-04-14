#ifndef _LOL_RENDER_H
#define _LOL_RENDER_H

#include "lk_struct.h"

void updateBone(MeshBone *skl, const Animation *anm, int frame);

/* *** used buffer *** */

void drawSknBUFFER(const Mesh *mesh, const GLuint buffers[], const GLint attributes[], const Texture *tex);

void drawBoneBUFFER(const GLuint buffers[], const GLuint count[], const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[]);

void drawAnmSknBUFFER(const Mesh *mesh, const GLuint buffers[], const GLint attributes[], const Texture *tex);

void drawAnimationBoneBUFFER(const MeshBone *skl, const GLuint buffers[], const GLuint count[], const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[]);

/* *** unused buffer *** */

void drawSkn(const Mesh *mesh, const GLint attributes[], const Texture *tex);

void drawBone(const MeshBone *skl, const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[]);

void drawAnmSkn(const Mesh *mesh, const GLint attributes[], const Texture *tex);

void drawAnimationBone(const MeshBone *skl, const GLint attributes[], const GLfloat color[][4], const GLfloat sizes[]);;

#endif
