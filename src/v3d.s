global math_v3d_new
global math_v3d_sub
global math_v3d_divs
global math_v3d_len
global math_v3d_norm
global math_v3d_dot
global math_v3d_cross
global math_v3d_print

extern sqrt
extern printf

section .text

math_v3d_new:
	mov rax, rdi
	movsd [rax   ], xmm0
	movsd [rax+8 ], xmm1
	movsd [rax+16], xmm2
	ret

math_v3d_sub:
	mov rax, rdi

	movsd xmm0, [rsi   ]
	movsd xmm1, [rsi+8 ]
	movsd xmm2, [rsi+16]

	subsd xmm0, [rdx   ]
	subsd xmm1, [rdx+8 ]
	subsd xmm2, [rdx+16]

	movsd [rax   ], xmm0
	movsd [rax+8 ], xmm1
	movsd [rax+16], xmm2
	ret


math_v3d_divs:
	mov rax, rdi

	movsd xmm1, [rsi   ]
	movsd xmm2, [rsi+8 ]
	movsd xmm3, [rsi+16]
	
	divsd xmm1, xmm0
	divsd xmm2, xmm0
	divsd xmm3, xmm0

	movsd [rax   ], xmm1
	movsd [rax+8 ], xmm2
	movsd [rax+16], xmm3

	ret

math_v3d_len:
	movsd xmm0, [rdi   ]
	movsd xmm1, [rdi+8 ]
	movsd xmm2, [rdi+16]

	mulsd xmm0, xmm0
	mulsd xmm1, xmm1
	mulsd xmm2, xmm2

	addsd xmm0, xmm1
	addsd xmm0, xmm2

	call sqrt
	
	ret

math_v3d_norm:
	push rbp
	mov rbp, rdi
	mov rdi, rsi
	call math_v3d_len
	mov rsi, rdi
	mov rdi, rbp
	pop rbp

	call math_v3d_divs
	mov rax, rdi
	ret

math_v3d_dot:
	movsd xmm0, [rdi   ]
	movsd xmm1, [rdi+8 ]
	movsd xmm2, [rdi+16]

	mulsd xmm0, [rsi   ]
	mulsd xmm1, [rsi+8 ]
	mulsd xmm2, [rsi+16]

	addsd xmm0, xmm1
	addsd xmm0, xmm2

	ret

math_v3d_cross:
	mov rax, rdi

	movsd xmm0, [rsi+8 ]
	mulsd xmm0, [rdx+16]

	movsd xmm4, [rsi+16]
	mulsd xmm4, [rdx+8 ]

	subsd xmm0, xmm4



	movsd xmm1, [rsi+16]
	mulsd xmm1, [rdx   ]

	movsd xmm4, [rsi   ]
	mulsd xmm4, [rdx+16]

	subsd xmm1, xmm4



	movsd xmm2, [rsi  ]
	mulsd xmm2, [rdx+8]

	movsd xmm4, [rsi+8]
	mulsd xmm4, [rdx  ]

	subsd xmm2, xmm4



	movsd [rax   ], xmm0
	movsd [rax+8 ], xmm1
	movsd [rax+16], xmm2


	ret

math_v3d_print:
	movsd xmm0, [rdi   ]
	movsd xmm1, [rdi+8 ]
	movsd xmm2, [rdi+16]
	mov rdi, print_string
	mov eax, 3
	sub rsp, 8
	call printf
	add rsp, 8
	ret

section .data
print_string: db "v3d(x: %f, y: %f, z: %f)",10,0
