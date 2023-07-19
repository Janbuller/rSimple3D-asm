#ifndef MESH_H__35B904D2
#define MESH_H__35B904D2

#include "v3d.h"
#include "triangle.h"

typedef struct mesh_s {
    struct {
        v3d* arr;
        unsigned int size;
        unsigned int alloc;
    } verts;

    struct {
        triangle* arr;
        unsigned int size;
        unsigned int alloc;
    } tris;
} mesh;

mesh gfx_mesh_new(void);
void gfx_mesh_destroy(mesh* m);

void gfx_mesh_grow_vert(mesh* m);
void gfx_mesh_grow_tris(mesh* m);

void gfx_mesh_push_vert(mesh* m, v3d v);
void gfx_mesh_push_tri(mesh* m, triangle t);

mesh gfx_mesh_new_from_obj(char* path);

#endif
