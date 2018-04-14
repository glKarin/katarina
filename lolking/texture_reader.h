#ifndef _TEXTURE_READER_H
#define _TEXTURE_READER_H

class QIODevice;
class Texture;

Texture * read_texture(QIODevice *in);
void free_texture(Texture *tex);

Texture * read_texture_from_file(const char *file);

#endif
