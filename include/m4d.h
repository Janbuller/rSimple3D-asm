#ifndef M4D_H__5692C50C
#define M4D_H__5692C50C

#include "v3d.h"

typedef struct m4d_s {
    double d[4][4];
} m4d;

m4d math_m4d_new(void);
m4d math_m4d_identity(void);

m4d math_m4d_translate(v3d* v);
m4d math_m4d_rotate(double angle, v3d* axis);
m4d math_m4d_scale(v3d* scalar);

m4d math_m4d_multiply(m4d* m1, m4d* m2);
v3d math_m4d_multiply_v3d(m4d* m, v3d* v, double last_bit);

m4d math_m4d_transform(v3d* pos, v3d* rot, v3d* scl);

m4d math_m4d_projection(double fov, double aspect, double near, double far);
m4d math_m4d_view(v3d* pos, v3d* rot);

#endif
