global gfx_triangle_draw
global gfx_triangle_mult_with_m4d

extern DrawTriangle
extern math_m4d_multiply_v3d

section .text

gfx_triangle_draw:
	push rax

	cvtsd2ss xmm0, [rdi+8]
	shufps xmm0,xmm0, 0b11110000
	cvtsd2ss xmm0, [rdi]

	cvtsd2ss xmm1, [rdi+32]
	shufps xmm1,xmm1, 0b11110000
	cvtsd2ss xmm1, [rdi+24]

	cvtsd2ss xmm2, [rdi+56]
	shufps xmm2,xmm2, 0b11110000
	cvtsd2ss xmm2, [rdi+48]

	mov rdi, rsi
	call DrawTriangle

	pop rax
	ret

gfx_triangle_mult_with_m4d:
	push rdi

	push rsi
	mov rsi, rdx
	pop rdx
	mov rcx,1
	cvtsi2sd xmm0, rcx

	push rdi
	push rsi
	push rdx
	sub rsp, 8

	call math_m4d_multiply_v3d

	
	add rsp, 8
	pop rdx
	pop rsi
	pop rdi


	add rdi, 8*3
	add rdx, 8*3

	mov rcx,1
	cvtsi2sd xmm0, rcx

	push rdi
	push rsi
	push rdx
	sub rsp, 8

	call math_m4d_multiply_v3d

	add rsp, 8
	pop rdx
	pop rsi
	pop rdi


	add rdi, 8*3
	add rdx, 8*3

	mov rcx,1
	cvtsi2sd xmm0, rcx

	call math_m4d_multiply_v3d

	pop rdi

	ret
