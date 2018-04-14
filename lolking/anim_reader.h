#ifndef _ANIM_READER_H
#define _ANIM_READER_H

class QIODevice;
class Anim;

Anim * read_anim(QIODevice *in);
void free_anim(Anim *anim);

#endif
