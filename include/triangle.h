#ifndef TRIANGLE_H__77CCB8EE
#define TRIANGLE_H__77CCB8EE

#include "v3d.h"
#include "m4d.h"
#include <raylib.h>

typedef struct triangle_s {
    v3d p[3];
} triangle;

void gfx_triangle_draw(triangle *tri, Color col);
triangle gfx_triangle_mult_with_m4d(triangle *tri, m4d* m);

#endif
