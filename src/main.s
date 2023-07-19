global main

extern SetConfigFlags
extern InitWindow
extern WindowShouldClose
extern CloseWindow
extern ClearBackground

extern BeginDrawing
extern EndDrawing

extern GetScreenWidth
extern GetScreenHeight

extern SetTraceLogLevel


extern GetTime
extern sin


extern gfx_mesh_new_from_obj
extern math_m4d_transform
extern math_m4d_rotate
extern math_m4d_multiply
extern math_m4d_projection
extern gfx_triangle_mult_with_m4d
extern math_v3d_sub
extern math_v3d_cross
extern math_v3d_norm
extern math_v3d_dot
extern gfx_triangle_draw


; converts a triangle* from normalized-device-coords (-1.0<->1.0)
; to screen-space coords using GetScreenWidth and GetScreenHeight functions
ndc2screen:
	push rdi
	sub rsp, 16

	call GetScreenWidth
	cvtsi2sd xmm0, rax
	movsd xmm1, [_2.0]
	divsd xmm0, xmm1

	movsd [rsp+8], xmm0

	call GetScreenHeight
	cvtsi2sd xmm0, rax
	movsd xmm1, [_2.0]
	divsd xmm0, xmm1

	movsd xmm15, xmm0	; xmm15 = HalfHeight
	movsd xmm14, [rsp+8]	; xmm14 = HalfWidth

	add rsp, 16
	pop rdi

	movsd xmm1, [_1.0]

	movsd xmm0, [rdi]
	addsd xmm0, xmm1
	mulsd xmm0, xmm14
	movsd [rdi], xmm0

	movsd xmm0, [rdi+8]
	addsd xmm0, xmm1
	mulsd xmm0, xmm15
	movsd [rdi+8], xmm0


	movsd xmm0, [rdi+24]
	addsd xmm0, xmm1
	mulsd xmm0, xmm14
	movsd [rdi+24], xmm0

	movsd xmm0, [rdi+32]
	addsd xmm0, xmm1
	mulsd xmm0, xmm15
	movsd [rdi+32], xmm0


	movsd xmm0, [rdi+48]
	addsd xmm0, xmm1
	mulsd xmm0, xmm14
	movsd [rdi+48], xmm0

	movsd xmm0, [rdi+56]
	addsd xmm0, xmm1
	mulsd xmm0, xmm15
	movsd [rdi+56], xmm0

	ret


; draws a triangle* with a monochrome color
draw_tri_color:
	movsd xmm1, [_255.0]
	mulsd xmm0, xmm1
	cvtsd2si rax, xmm0

	push rbp
	mov rbp, rsp

	sub rsp, 16
	mov [rbp-4], al
	mov [rbp-3], al
	mov [rbp-2], al
	mov al, 255
	mov [rbp-1], al


	xor rsi,rsi
	mov esi, [rsp+12]
	call gfx_triangle_draw


	add rsp, 16

	pop rbp
	ret

main:
	push rbp
	mov rbp, rsp

	mov rdi, 7
	call SetTraceLogLevel	; Disable raylib logging


	sub rsp, 32
	mov rdi, rsp
	mov rsi, _mesh_path
	call gfx_mesh_new_from_obj ;[rbp-32] = mesh

	sub rsp, 128
	mov rdi, rsp
	mov rsi, _pos
	mov rdx, _rot
	mov rcx, _scl
	call math_m4d_transform	; [rbp-160] = def_obj_model_mat



	mov rdi, 68		; VSYNC | RESIZABLE
	call SetConfigFlags


	mov rdi, 640
	mov rsi, 480
	mov rdx, _window_title

	call InitWindow
	
.main_loop:
	call WindowShouldClose
	cmp rax, 0
	jne .end_main_loop

	call BeginDrawing


	mov edi, [_background]
	call ClearBackground

	sub rsp, 128*3		; Make space for 3 matrices

	call GetTime
	movsd xmm1, [_2.0]
	mulsd xmm0, xmm1
	call sin
	movsd xmm1, [_0.5]
	mulsd xmm0, xmm1
	mov rsi, _rot_angle
	lea rdi, [rbp-288]	; First matrix spot on stack
	call math_m4d_rotate	; [rbp-288] = tmp_rot_mat


	lea rdi, [rbp-416]	; Second matrix spot on stack
	lea rsi, [rbp-288]	; rsi = tmp_rot_mat
	lea rdx, [rbp-160]	; rdx = def_obj_model_mat
	call math_m4d_multiply	; [rbp-416] = obj_model_mat


	xor rax,rax
	call GetScreenHeight
	push rax
	call GetScreenWidth

	cvtsi2sd xmm1, [rsp]
	cvtsi2sd xmm0, eax
	divsd xmm1, xmm0
	add rsp, 8

	movsd xmm0, [_fov]
	movsd xmm2, [_near]
	movsd xmm3, [_far]

	lea rdi, [rbp-544]	 ; Third matrix spot on stack
	call math_m4d_projection ; [rbp-544] = proj_mat

	lea rax, [rbp-32]
	xor rcx,rcx
	mov ecx, [rax+24]
	mov r10, 0
.tri_loop:
	push rcx		; push loop decrementer to stack


	sub rsp, 72		; [rbp-624] = tri_trans
	mov rdi, rsp
	mov rsi, [rbp-16]
	add rsi, r10
	push rsi

	add r10, 72		; add to loop incrementer
	push r10		; push loop incrementer to stack

	lea rdx, [rbp-416]
	call gfx_triangle_mult_with_m4d

	sub rsp, 72		; make room for 3 vectors

	lea rdi, [rsp+48]
	lea rsi, [rbp-624+24]
	lea rdx, [rbp-624]
	call math_v3d_sub	; tmp [rsp+48] = l1

	lea rdi, [rsp+24]
	lea rsi, [rbp-624+48]
	lea rdx, [rbp-624]
	call math_v3d_sub	; tmp [rsp+24] = l2

	mov rdi, rsp
	lea rsi, [rsp+48]
	lea rdx, [rsp+24]
	call math_v3d_cross	; tmp [rsp] = norm (not-normalized)

	lea rdi, [rbp-664]
	mov rsi, rsp
	call math_v3d_norm	; [rbp-664] = norm


	lea rdi, [rbp-664]	; this is to check whether normal is facing away from camera
	lea rsi, [rbp-624+24]	; normally, 2nd param would be tri_trans.p[1] - cam_pos, 
	call math_v3d_dot	; but since cam is always at (0,0,0), this can be saved.

	movsd xmm1, [_0.0]
	comisd xmm0, xmm1
	ja .no_draw
.draw:
	sub rsp, 128+8
	mov rdi, rsp
	lea rsi, [rbp-416]
	lea rdx, [rbp-544]
	call math_m4d_multiply	; [rbp-848] = proj_obj_mat


	sub rsp, 24
	mov rdi, rsp
	mov rsi, _light_dir
	call math_v3d_norm	; [rbp-872] = light_dir (normalized)

	sub rsp, 72
	mov rdi, rsp
	mov rsi, [rbp-632]
	lea rdx, [rbp-848]
	call gfx_triangle_mult_with_m4d ; [rbp-944] = tri_proj

	mov rdi, rsp
	call ndc2screen

	lea rdi, [rbp-664]
	lea rsi, [rbp-872]
	call math_v3d_dot	; xmm0 = dot(norm, light_dir)
	movsd xmm1, [_0.0]

	comisd xmm0, xmm1
	ja .no_clip_color
	movsd xmm0, xmm1
.no_clip_color:

	lea rdi, [rbp-944]
	call draw_tri_color

	add rsp, 128+8+24+72


.no_draw:

	add rsp, 72
	pop r10
	pop rsi
	add rsp, 72
	pop rcx


	dec rcx
	jnz .tri_loop

	add rsp, 128*3
	call EndDrawing

	jmp .main_loop
.end_main_loop:

	call CloseWindow


	add rsp, 128+32
	pop rbp
	mov rax, 0
	ret


section .data

_background: db 0, 0, 0, 255

_pos: dq 0.0, 0.0, 10.0
_rot: dq 0.0, 0.0, 0.0
_scl: dq 1.0, 1.0, 1.0


_rot_angle: dq 1.0, 1.0, 0.0


_fov:  dq 90.0
_near: dq 0.1
_far:  dq 100.0

_light_dir: dq 0.0, 0.0, -1.0

	
_2.0: dq 2.0
_0.5: dq 0.5
_0.0: dq 0.0
_1.0: dq 1.0
_255.0: dq 255.0

_mesh_path: db "res/teapot.obj",0

_window_title: db "rSimple3D-asm!",0
