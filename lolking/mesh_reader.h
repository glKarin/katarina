#ifndef _MESH_READER_H
#define _MESH_READER_H

class QIODevice;
class Mesh;

Mesh * read_mesh(QIODevice *in);
void free_mesh(Mesh *mesh);

#endif // MESH_READER_H
