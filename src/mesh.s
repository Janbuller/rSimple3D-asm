global gfx_mesh_new
global gfx_mesh_destroy

global gfx_mesh_push_vert
global gfx_mesh_push_tri

global gfx_mesh_grow_vert

global gfx_mesh_new_from_obj


extern free
extern malloc
extern fopen
extern fclose
extern fgets
extern sscanf


%define VERT_START_SIZE  256
%define VERT_GROWTH_FACTOR 2

%define TRI_START_SIZE  128
%define TRI_GROWTH_FACTOR 2


gfx_mesh_new:
	sub rsp, 8
	mov [rsp], rdi

	mov [rdi+8], dword 0		     ; verts-size  = 0
	mov [rdi+8+4], dword VERT_START_SIZE ; verts.alloc = VERT_START_SIZE

	mov [rdi+8*3], dword 0		      ; tris.size  = 0
	mov [rdi+8*3+4], dword TRI_START_SIZE ; tris.alloc = TRIS_START_SIZE


	mov rdi, 8*3 * VERT_START_SIZE ; rdi = size(v3d) * VERT_START_SIZE
	call malloc		       ; malloc(rdi)

	mov rdi, [rsp]		; rdi = mesh-ptr
	mov [rdi], rax		; *rdi = malloc()


	mov rdi, 8*3*3 * TRI_START_SIZE  ; rdi = size(triangle) * VERT_START_SIZE
	call malloc		         ; malloc(rdi)

	mov rdi, [rsp]		; rdi = mesh-ptr
	mov [rdi+8*2], rax	; *rdi = malloc()


	add rsp, 8
	ret

gfx_mesh_destroy:
	push rbx
	mov rbx, rdi

	mov rdi, [rdi]
	call free

	mov rdi, [rbx+8*2]
	call free

	pop rbx
	
	ret

gfx_mesh_grow_vert:
	push rbp
	mov rbp, rsp
	sub rsp,8
	mov rax, [rdi]
	mov [rsp], rax		; rbp-8 = verts.arr*
	sub rsp,4
	mov eax, [rdi+8]
	mov [rsp], eax		; rbp-12 = verts.size
	sub rsp,4
	mov eax, [rdi+8+4]
	mov [rsp], eax		; rbp-16 = verts.alloc
	sub rsp, 8
	mov [rsp], rdi		; rbp-24 = mesh*

	xor rdi,rdi
	mov edi, [rbp-16]
	imul edi,edi,VERT_GROWTH_FACTOR * 8*3
	call malloc

	sub rsp, 8
	mov [rsp], rax		; rbp-32 = newarr*

	mov r10, [rbp-8]

	mov r11, 0

	xor rcx,rcx
	mov ecx, [rbp-12]
.loop:
	add rax, r11
	add r10, r11

	mov rsi, qword [r10]
	mov [rax], rsi
	mov rsi, qword [r10+8]
	mov [rax+8], rsi
	mov rsi, qword [r10+16]
	mov [rax+16], rsi

	mov r11, 8*3
	loop .loop


	mov rdi, [rbp-8]
	call free

	mov rdi, [rbp-24]
	mov rax, [rbp-32]
	mov [rdi], rax

	mov eax, [rbp-16]
	imul eax,eax,VERT_GROWTH_FACTOR
	mov [rdi+12], eax
	

	add rsp, 8*3+4*2
	pop rbp
	ret

gfx_mesh_grow_tris:
	push rbp
	mov rbp, rsp
	sub rsp,8
	mov rax, [rdi+16]
	mov [rsp], rax		; rbp-8 = tris.arr*
	sub rsp,4
	mov eax, [rdi+16+8]
	mov [rsp], eax		; rbp-12 = tris.size
	sub rsp,4
	mov eax, [rdi+16+8+4]
	mov [rsp], eax		; rbp-16 = tris.alloc
	sub rsp, 8
	mov [rsp], rdi		; rbp-24 = mesh*

	xor rdi,rdi
	mov edi, [rbp-16]
	imul edi,edi,TRI_GROWTH_FACTOR * 8*3*3
	call malloc

	sub rsp, 8
	mov [rsp], rax		; rbp-32 = newarr*

	mov r10, [rbp-8]

	mov r11, 0

	xor rcx,rcx
	mov ecx, [rbp-12]
.loop:
	add rax, r11
	add r10, r11

	mov rsi, qword [r10]
	mov [rax], rsi
	mov rsi, qword [r10+8]
	mov [rax+8], rsi
	mov rsi, qword [r10+16]
	mov [rax+16], rsi

	mov rsi, qword [r10+24]
	mov [rax+24], rsi
	mov rsi, qword [r10+32]
	mov [rax+32], rsi
	mov rsi, qword [r10+40]
	mov [rax+40], rsi

	mov rsi, qword [r10+48]
	mov [rax+48], rsi
	mov rsi, qword [r10+56]
	mov [rax+56], rsi
	mov rsi, qword [r10+64]
	mov [rax+64], rsi

	mov r11, 8*3*3
	loop .loop


	mov rdi, [rbp-8]
	call free

	mov rdi, [rbp-24]
	mov rax, [rbp-32]
	mov [rdi+16], rax

	mov eax, [rbp-16]
	imul eax,eax,TRI_GROWTH_FACTOR
	mov [rdi+16+12], eax
	

	add rsp, 8*3+4*2
	pop rbp
	ret

gfx_mesh_push_vert:
	xor rax,rax
	mov eax, dword [rdi+8]

	mov r11, rax
	mov eax, dword [rdi+8+4]
	cmp r11, rax

	jne .no_grow

	push rdi
	call gfx_mesh_grow_vert
	pop rdi

.no_grow:
	xor rax,rax
	mov eax, dword [rdi+8]

	imul rax, rax, 8*3
	mov r10, [rdi]
	add r10, rax

	lea rax, [rsp+8]
	mov r11, qword [rax]
	mov [r10], r11
	mov r11, qword [rax+8]
	mov [r10+8], r11
	mov r11, qword [rax+16]
	mov [r10+16], r11

	mov rax, qword [rdi+8]
	add rax, 1
	mov [rdi+8], qword rax
	ret

gfx_mesh_push_tri:
	xor rax,rax
	mov eax, dword [rdi+8*3]

	mov r11, rax
	mov eax, dword [rdi+8*3+4]
	cmp r11, rax

	jne .no_grow

	push rdi
	call gfx_mesh_grow_tris
	pop rdi

.no_grow:
	xor rax,rax
	mov eax, dword [rdi+8*3]

	imul rax, rax, 8*3*3
	mov r10, [rdi+8*2]
	add r10, rax

	lea rax, [rsp+8]
	mov r11, qword [rax]
	mov [r10], r11
	mov r11, qword [rax+8]
	mov [r10+8], r11
	mov r11, qword [rax+16]
	mov [r10+16], r11

	add rax, 24
	add r10, 24
	mov r11, qword [rax]
	mov [r10], r11
	mov r11, qword [rax+8]
	mov [r10+8], r11
	mov r11, qword [rax+16]
	mov [r10+16], r11

	add rax, 24
	add r10, 24
	mov r11, qword [rax]
	mov [r10], r11
	mov r11, qword [rax+8]
	mov [r10+8], r11
	mov r11, qword [rax+16]
	mov [r10+16], r11

	mov rax, qword [rdi+8*3]
	add rax, 1
	mov [rdi+8*3], qword rax
	ret


gfx_mesh_new_from_obj:
	push rbp
	mov rbp, rsp

	sub rsp, 8
	mov [rsp], rdi		     ; [rbp-8]   = mesh-return*
	sub rsp, 8+256+8*3+3*4+8*3*3 ; [rbp-16]  = file*
				     ; [rbp-272] = char[256] line-buffer
				     ; [rbp-296] = v3d
				     ; [rbp-308] = int[3] tri-idx
				     ; [rbp-380] = triangle
	sub rsp, 8		     ; [rbp-388] = char* path
	mov [rsp], rsi
	sub rsp, 12		; align stack with 16-byte boundry for function-call

	call gfx_mesh_new

	mov rdi, [rbp-388]
	mov rsi, _r
	call fopen
	mov [rbp-16], rax

.loop_lines:
	lea rdi, [rbp-272]
	mov rsi, 256
	mov rdx, [rbp-16]
	call fgets
	cmp rax, 0
	je .eof


	mov al, [rbp-272]
	cmp al, 'v'
	jne .not_vert

	lea rdi, [rbp-272]
	mov rsi, _v_sscanf_string
	lea rdx, [rbp-296]
	lea rcx, [rbp-296+8]
	lea r8, [rbp-296+16]
	mov al, 0

	call sscanf

	mov rdi, [rbp-8]
	lea rsi, [rbp-296]
	push qword [rsi+16]
	push qword [rsi+8]
	push qword [rsi]
	call gfx_mesh_push_vert
	add rsp, 24


	jmp .loop_lines
.not_vert:
	cmp al, 'f'
	jne .loop_lines


	lea rdi, [rbp-272]
	mov rsi, _f_sscanf_string
	lea rdx, [rbp-308]
	lea rcx, [rbp-308+4]
	lea r8, [rbp-308+8]
	mov al, 0

	call sscanf


	sub [rbp-308], dword 1
	sub [rbp-308+4], dword 1
	sub [rbp-308+8], dword 1


	mov rax, [rbp-8]
	mov rax, [rax]
	xor rcx,rcx
	mov ecx, [rbp-308+8]
	imul rcx,rcx,8*3
	add rax, rcx

	push qword [rax+16]
	push qword [rax+8]
	push qword [rax]


	mov rax, [rbp-8]
	mov rax, [rax]
	xor rcx,rcx
	mov ecx, [rbp-308+4]
	imul rcx,rcx,8*3
	add rax, rcx

	push qword [rax+16]
	push qword [rax+8]
	push qword [rax]


	mov rax, [rbp-8]
	mov rax, [rax]
	xor rcx,rcx
	mov ecx, [rbp-308]
	imul rcx,rcx,8*3
	add rax, rcx

	push qword [rax+16]
	push qword [rax+8]
	push qword [rax]


	mov rdi, [rbp-8]
	call gfx_mesh_push_tri
	add rsp, 8*9


	jmp .loop_lines
.eof:
	mov rdi, [rbp-16]
	call fclose

	add rsp, 8+8+256+8*3+3*4+8*3*3+8+12
	pop rbp
	ret

section .data
_r: db "r",0

_v_sscanf_string: db "%*c %lf %lf %lf",10,0
_f_sscanf_string: db "%*c %i %i %i",10,0

