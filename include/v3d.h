#ifndef V3D_H__5FCDE357
#define V3D_H__5FCDE357

typedef struct v3d_s {
    double x;
    double y;
    double z;
} v3d;

v3d math_v3d_new(double x, double y, double z);

v3d math_v3d_sub(v3d *vec1, v3d *vec2);

v3d math_v3d_divs(v3d *vec1, double scalar);

double math_v3d_len(v3d *vec1);
v3d math_v3d_norm(v3d *vec1);

v3d math_v3d_cross(v3d *vec1, v3d* vec2);
double math_v3d_dot(v3d *vec1, v3d* vec2);

void math_v3d_print(v3d *vec1);

#endif
