global math_m4d_new
global math_m4d_identity
global math_m4d_translate
global math_m4d_rotate
global math_m4d_scale
global math_m4d_multiply
global math_m4d_multiply_v3d
global math_m4d_transform
global math_m4d_projection

extern math_v3d_divs
extern cos
extern sin
extern tan



%define i(x,y) (y*8+x*4*8)	; Index for mat4, add to mat4-ptr
%macro iR 3			; iR = index_register(register, x, y)
	push rax
	push rdx
	push r11

	mov rax, %3
	sub rax, 1
	mov r11, 8
	mul r11
	mov %1, rax

	mov rax, %2
	sub rax, 1
	mov r11, 32
	mul r11
	add %1, rax

	pop r11
	pop rdx
	pop rax
%endmacro

section .text

math_m4d_new:
	mov rax, rdi
	mov rsi, 0
	cvtsi2sd xmm0, rsi

	mov rcx, 16
.math_m4d_new_loop:
	movsd [rdi], xmm0
	add rdi, 8

	loop .math_m4d_new_loop
	ret


math_m4d_identity:
	sub rsp, 8
	call math_m4d_new
	add rsp, 8
	
	mov rdi, rax

	mov rsi, 1
	cvtsi2sd xmm0, rsi

	movsd [rdi], xmm0
	movsd [rdi+8*5], xmm0
	movsd [rdi+8*10], xmm0
	movsd [rdi+8*15], xmm0

	ret

math_m4d_translate:
	push rsi
	call math_m4d_identity
	mov rax, rdi
	pop rsi

	movsd xmm0, [rsi]
	movsd [rdi+8*12], xmm0
	movsd xmm0, [rsi+8]
	movsd [rdi+8*13], xmm0
	movsd xmm0, [rsi+16]
	movsd [rdi+8*14], xmm0

	ret

%define vx 0
%define vy 8
%define vz 16

math_m4d_rotate:
	push rsi
	sub rsp, 16
	movsd [rsp], xmm0

	call math_m4d_identity

	movsd xmm0, [rsp]

	call cos
	movsd xmm7,xmm0		; xmm7 = cos(angle)
	movsd xmm0,[rsp]
	call sin
	movsd xmm6,xmm0		; xmm6 = sin(angle)
	movsd xmm5,[_1.0]
	subsd xmm5,xmm7	        ; xmm5 = 1.0 - cos(angle)

	add rsp, 16
	pop rsi


	; [0,0]
	movsd xmm0, [rsi+vx]
	mulsd xmm0, [rsi+vx]
	mulsd xmm0, xmm5
	addsd xmm0, xmm7
	movsd [rdi+i(0,0)], xmm0


	; [0,1]
	movsd xmm0, [rsi+vx]
	mulsd xmm0, [rsi+vy]

	mulsd xmm0, xmm5
	movsd xmm1, [rsi+vz]
	mulsd xmm1, xmm6

	subsd xmm0, xmm1
	movsd [rdi+i(0,1)], xmm0


	; [0,2]
	movsd xmm0, [rsi+vx]
	mulsd xmm0, [rsi+vz]

	mulsd xmm0, xmm5
	movsd xmm1, [rsi+vy]
	mulsd xmm1, xmm6

	addsd xmm0, xmm1
	movsd [rdi+i(0,2)], xmm0


	; [1, 0]
	movsd xmm0, [rsi+vy]
	mulsd xmm0, [rsi+vx]

	mulsd xmm0, xmm5
	movsd xmm1, [rsi+vz]
	mulsd xmm1, xmm6

	addsd xmm0, xmm1
	movsd [rdi+i(1, 0)], xmm0


	; [1, 1]
	movsd xmm0, [rsi+vy]
	mulsd xmm0, [rsi+vy]
	mulsd xmm0, xmm5
	addsd xmm0, xmm7
	movsd [rdi+i(1,1)], xmm0


	; [1, 2]
	movsd xmm0, [rsi+vy]
	mulsd xmm0, [rsi+vz]

	mulsd xmm0, xmm5
	movsd xmm1, [rsi+vx]
	mulsd xmm1, xmm6

	subsd xmm0, xmm1
	movsd [rdi+i(1, 2)], xmm0


	; [2, 0]
	movsd xmm0, [rsi+vz]
	mulsd xmm0, [rsi+vx]

	mulsd xmm0, xmm5
	movsd xmm1, [rsi+vy]
	mulsd xmm1, xmm6

	subsd xmm0, xmm1
	movsd [rdi+i(2, 0)], xmm0


	; [2, 1]
	movsd xmm0, [rsi+vz]
	mulsd xmm0, [rsi+vy]

	mulsd xmm0, xmm5
	movsd xmm1, [rsi+vx]
	mulsd xmm1, xmm6

	addsd xmm0, xmm1
	movsd [rdi+i(2, 1)], xmm0


	; [2, 2]
	movsd xmm0, [rsi+vz]
	mulsd xmm0, [rsi+vz]
	mulsd xmm0, xmm5
	addsd xmm0, xmm7
	movsd [rdi+i(2,2)], xmm0

	ret

math_m4d_scale:
	push rsi

	call math_m4d_new

	pop rsi

	mov rdi, rax

	movsd xmm0, [rsi]
	movsd [rdi], xmm0
	movsd xmm0, [rsi+8]
	movsd [rdi+8*5], xmm0
	movsd xmm0, [rsi+16]
	movsd [rdi+8*10], xmm0

	mov rsi, 1
	cvtsi2sd xmm0, rsi
	movsd [rdi+8*15], xmm0
	
	ret

math_m4d_multiply:
	mov rcx, 4
.loop_1:
	mov r8, 4
.loop_2:
	iR r10,1,rcx
	iR r9,r8,1
	movsd xmm0, [rsi+r9]
	mulsd xmm0, [rdx+r10]

	add r10, 32
	add r9, 8
	movsd xmm1, [rsi+r9]
	mulsd xmm1, [rdx+r10]
	addsd xmm0, xmm1

	add r10, 32
	add r9, 8
	movsd xmm1, [rsi+r9]
	mulsd xmm1, [rdx+r10]
	addsd xmm0, xmm1

	add r10, 32
	add r9, 8
	movsd xmm1, [rsi+r9]
	mulsd xmm1, [rdx+r10]
	addsd xmm0, xmm1

	iR r10,r8,rcx
	movsd [rdi+r10], xmm0

	dec r8
	jnz .loop_2

	dec rcx
	jnz .loop_1

	ret

math_m4d_multiply_v3d:
	movsd xmm1, [rsi]
	mulsd xmm1, [rdx]

	movsd xmm2, [rsi+8*4]
	mulsd xmm2, [rdx+8]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*8]
	mulsd xmm2, [rdx+16]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*12]
	mulsd xmm2, xmm0
	addsd xmm1, xmm2

	movsd [rdi], xmm1


	movsd xmm1, [rsi+8]
	mulsd xmm1, [rdx]

	movsd xmm2, [rsi+8*4+8]
	mulsd xmm2, [rdx+8]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*8+8]
	mulsd xmm2, [rdx+16]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*12+8]
	mulsd xmm2, xmm0
	addsd xmm1, xmm2

	movsd [rdi+8], xmm1


	movsd xmm1, [rsi+8*2]
	mulsd xmm1, [rdx]

	movsd xmm2, [rsi+8*4+8*2]
	mulsd xmm2, [rdx+8]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*8+8*2]
	mulsd xmm2, [rdx+16]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*12+8*2]
	mulsd xmm2, xmm0
	addsd xmm1, xmm2

	movsd [rdi+8*2], xmm1


	movsd xmm1, [rsi+8*3]
	mulsd xmm1, [rdx]

	movsd xmm2, [rsi+8*4+8*3]
	mulsd xmm2, [rdx+8]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*8+8*3]
	mulsd xmm2, [rdx+16]
	addsd xmm1, xmm2

	movsd xmm2, [rsi+8*12+8*3]
	mulsd xmm2, xmm0
	addsd xmm1, xmm2
	movsd xmm2, xmm1

	mov r10, 0
	cvtsi2sd xmm1, r10

	comisd xmm0, xmm1

	je .no_division

	movsd xmm0, xmm2
	mov rsi, rdi

	call math_v3d_divs

.no_division:
	
	ret

math_m4d_transform:
	push rbp
	mov rbp, rsp

	sub rsp, 8
	mov [rsp], rdi 		; return-m4d*
	sub rsp, 8
	mov [rsp], rsi		; pos*
	sub rsp, 8
	mov [rsp], rdx		; rot*
	sub rsp, 8
	mov [rsp], rcx		; scl*


	call math_m4d_new


	sub rsp, 128		; translation-mat
	mov rdi, rsp
	mov rsi, [rbp-8*2]
	call math_m4d_translate



	sub rsp, 128		; rotX-mat
	mov rdi, rsp

	mov rax, [rbp-8*3]
	movsd xmm0, [rax+vx]

	mov rsi, _vX
	call math_m4d_rotate



	sub rsp, 128		; rotY-mat
	mov rdi, rsp

	mov rax, [rbp-8*3]
	movsd xmm0, [rax + vy]

	mov rsi, _vY
	call math_m4d_rotate



	sub rsp, 128		; rotZ-mat
	mov rdi, rsp

	mov rax, [rbp-8*3]
	movsd xmm0, [rax + vz]

	mov rsi, _vZ
	call math_m4d_rotate



	sub rsp, 128		; scale-mat
	mov rdi, rsp

	mov rsi, [rbp-8*4]
	call math_m4d_scale


	
	sub rsp, 128		; inner_rot-mat
	mov rdi, rsp

	mov rsi, rbp
	sub rsi, 8*4 + 128*3
	mov rdx, rbp
	sub rdx, 8*4 + 128*4
	call math_m4d_multiply


	
	sub rsp, 128		; rot-mat
	mov rdi, rsp

	mov rsi, rbp
	sub rsi, 8*4 + 128*2
	mov rdx, rbp
	sub rdx, 8*4 + 128*6
	call math_m4d_multiply



	mov rdi, [rsp + 8*3 + 128*7] ; result-mat = scale * rot-mat

	mov rsi, rbp
	sub rsi, 8*4 + 128*5
	mov rdx, rbp
	sub rdx, 8*4 + 128*7
	call math_m4d_multiply



	mov rsi, rdi		; result-mat = result * trans
	mov rdx, rbp
	sub rdx, 8*4 + 128
	call math_m4d_multiply



	add rsp,  8*4 + 128*7
	pop rbp
	ret

math_m4d_projection:
	push rbp
	mov rbp,rsp

	sub rsp,16		; [rbp-16*1]
	movdqu [rsp], xmm0	; fov

	sub rsp,16		; [rbp-16*2]
	movdqu [rsp], xmm1	; aspect

	sub rsp,16		; [rbp-16*3]
	movdqu [rsp], xmm2	; near

	sub rsp,16		; [rbp-16*4]
	movdqu [rsp], xmm3	; far



	push rdi

	call math_m4d_new

	movdqu xmm0, [rbp-16]
	mulsd xmm0, [deg2rad]
	call tan

	pop rdi


	movsd xmm1, [_1.0]
	divsd xmm1, xmm0

	sub rsp,16		; [rbp-16*5]
	movdqu [rsp], xmm1	; fov_rad_inv



	movdqu xmm0, [rbp-16*2]
	mulsd xmm0,xmm1

	movsd [rdi+i(0,0)], xmm0 ; res[0][0] = aspect * fov_rad_inv



	movsd [rdi+i(1,1)], xmm1 ; res[1][1] = fov_rad_inv



	movdqu xmm2, [rbp-16*3]	; xmm2 = near
	movdqu xmm3, [rbp-16*4]	; xmm3 = far

	movsd xmm0, xmm3
	addsd xmm0, xmm2
	mulsd xmm0, [_n1.0]

	movsd xmm1, xmm3
	subsd xmm1, xmm2

	divsd xmm0, xmm1

	movsd [rdi+i(2,2)], xmm0 ; res[2][2] = -(far + near) / (far - near)

	

	movsd xmm0, [_2.0]
	movsd xmm1, xmm3
	mulsd xmm0, xmm1
	movsd xmm1, xmm2
	mulsd xmm0, xmm1
	mulsd xmm0, [_n1.0]

	movsd xmm1, xmm3
	subsd xmm1, xmm2

	divsd xmm0, xmm1

	movsd [rdi+i(3,2)], xmm0 ; res[3][2] = -(2 * far * near) / (far - near)



	movsd xmm0, [_n1.0]
	movsd [rdi+i(2,3)], xmm0 ; res[2][3] = -1


	add rsp,16*5
	pop rbp
	ret

section .data
	_2.0: dq 2.0
	_1.0: dq 1.0
	_0.0: dq 0.0
	_n1.0: dq -1.0

deg2rad: dq 0.00872664626

_vZ: dq 0.0
_vY: dq 0.0
_vX: dq 1.0, 0.0, 0.0

_dScl: dq 1.0, 1.0, 1.0
