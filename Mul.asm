printf		proto
strlen		proto
malloc		proto
free		proto
sprintf_s	proto
ExitProcess proto

.data
	fmt				db "%lld x %lld = %s ", 0
	fmt1			db "%llu / %llu = %llu ", 0
	line			dw 10
	wordmaxsse		dq 65535
	dwordmaxsse		dq 4294967295
	qwordmaxsse		dq -1
	avx2			db 0
	src				dq ?
	target_length	db ?
	current_length	db ?
	padding			db ?
	zero			dw "0"
	sizev			db ?
	sizev1			db ?
	len				db ?
	len1			db ?
	len2			db ?
	len3			db ?
	len4			db ?
	sum				db ?
	carry			db 0
	sizesrc			db ?
	sizedest		db ?
	swap			dq ?
	temp			dq ?
	temp1			dq ?
	borrow			db 0
	negv			db 0
	num				db "00000000000000000000%020llu", 0
	hex				db "18446744073709551616", 0
	hex1			db "295147905179352825856", 0
	hex2			db "4722366482869645213696", 0
	hex3			db "75557863725914323419136", 0
	hex4			db "1208925819614629174706176", 0
	hex5			db "19342813113834066795298816", 0
	hex6			db "309485009821345068724781056", 0
	hex7			db "4951760157141521099596496896", 0
	hex8			db "79228162514264337593543950336", 0
	hex9			db "1267650600228229401496703205376", 0
	hex10			db "20282409603651670423947251286016", 0
	hex11			db "324518553658426726783156020576256", 0
	hex12			db "5192296858534827628530496329220096", 0
	hex13			db "83076749736557242056487941267521536", 0
	hex14			db "1329227995784915872903807060280344576", 0
	hex15			db "21267647932558653966460912964485513216", 0
	hex16			db "0340282366920938463463374607431768211456", 0
	number			db 41 dup (?)
	sign2			db ?
	sign3			db 2 dup (?)
	sign4			db 2 dup (?)
	align			16
	multiplicand	dq 2 dup (?)
	multiplier		dq 2 dup (?)
	sign			dq 2 dup (?)
	sign1			dq 2 dup (?)
	temp2			dq 2 dup (?)
	dividend		dq -1, -1
	divisor			dq 1, 1
	res4			dq 2 dup (?)

dat32	segment align(32) 'dat32'
	res		dq 4 dup (?)
	res1	dq 4 dup (?)
	res2	dq 4 dup (?)
	res3	dq 4 dup (?)
dat32	ends

.code
mainCRTStartup	proc
	sub		rsp, 56

	mov		eax, 7
	xor		ecx, ecx
	cpuid

	test	ebx, 020h
	jz		f0

	mov		avx2, 1
f0:
	lea		rbp, multiplicand
	lea		rdi, multiplier

	xor		ebx, ebx
l0:
	rdrand	rax
	mov		qword ptr [rbp + rbx * 8], rax
	rdrand	rax
	mov		qword ptr [rdi + rbx * 8], rax

	inc		bl

	cmp		bl, 1
	jle		l0

	mov		rcx, rbp
	mov		rdx, rdi
	call	pmulqs

	lea		rbp, res
	mov		rbp, rax

	xor		bl, bl
l1:
	lea		rbp, res
	mov		eax, ebx
	inc		al
	imul	ax, 2
	dec		al
	mov		rcx, qword ptr [rbp + rax * 8]
	dec		al
	mov		rdx, qword ptr [rbp + rax * 8]
	lea		r8, number
	mov		r9d, lengthof number
	mov		qword ptr 32 [rsp], 1
	mov		r12b, byte ptr 32 [rsp]
	call	cvti2s

	lea		rdi, multiplicand
	lea		rsi, multiplier
	lea		rcx, fmt
	mov		rdx, qword ptr [rdi + rbx * 8]
	mov		r8, qword ptr [rsi + rbx * 8]
	lea		r9, number
	call	printf

	inc		bl

	cmp		bl, 1
	jle		l1

	lea		rcx, line
	call	printf

	lea		rcx, dividend
	lea		rdx, divisor
	lea		r8, res4
	xor		r9d, r9d
	call	divf

	lea		rbp, dividend
	lea		rdi, divisor
	lea		rsi, res4

	xor		ebx, ebx
l2:
	lea		rcx, fmt1
	mov		rdx, qword ptr [rbp + rbx * 8]
	mov		r8, qword ptr [rdi + rbx * 8]
	mov		r9, qword ptr [rsi + rbx * 8]
	call	printf

	inc		bl

	cmp		bl, 1
	jle		l2

	xor		ecx, ecx
	call	ExitProcess
mainCRTStartup	endp
pmulq			proc
	cmp			avx2, 0
	jz			false

	movq		xmm0, qword ptr [rcx]
	movq		xmm1, qword ptr [rcx + 8]
	vinsertf128	ymm0, ymm0, xmm1, 1
	movq		xmm1, qword ptr [rdx]
	movq		xmm2, qword ptr [rdx + 8]
	vinsertf128	ymm1, ymm1, xmm2, 1
	movq		xmm2, qword ptr wordmaxsse
	vinsertf128	ymm2, ymm2, xmm2, 1
	movq		xmm3, qword ptr dwordmaxsse
	vinsertf128	ymm3, ymm3, xmm3, 1
	vmovdqa		ymm4, ymm0
	vmovdqa		ymm5, ymm0
	vmovdqa		ymm6, ymm0
	vmovdqa		ymm7, ymm0
	vmovdqa		ymm8, ymm1
	vmovdqa		ymm9, ymm1
	vmovdqa		ymm10, ymm1
	vmovdqa		ymm11, ymm1
	vpand		ymm4, ymm4, ymm2
	vpsrlq		ymm5, ymm5, 16
	vpand		ymm5, ymm5, ymm2
	vpsrlq		ymm6, ymm6, 32
	vpand		ymm6, ymm6, ymm2
	vpsrlq		ymm7, ymm7, 48
	vpand		ymm7, ymm7, ymm2
	vpand		ymm8, ymm8, ymm2
	vpsrlq		ymm9, ymm9, 16
	vpand		ymm9, ymm9, ymm2
	vpsrlq		ymm10, ymm10, 32
	vpand		ymm10, ymm10, ymm2
	vpsrlq		ymm11, ymm11, 48
	vpand		ymm11, ymm11, ymm2

	; hex x hex1ll
	vmovdqa		ymm1, ymm8
	vmovdqa		ymm12, ymm8
	vmovdqa		ymm13, ymm8
	vpmuldq		ymm8, ymm8, ymm4
	vpmuldq		ymm12, ymm12, ymm5
	vpmuldq		ymm13, ymm13, ymm6
	vpmuldq		ymm1, ymm1, ymm7
	vmovdqa		ymm0, ymm8
	vpsllq		ymm12, ymm12, 16
	vpaddq		ymm0, ymm0, ymm12
	vmovdqa		ymm8, ymm0
	vpsrlq		ymm8, ymm8, 32
	vpaddq		ymm8, ymm8, ymm13
	vpand		ymm0, ymm0, ymm3
	vpsllq		ymm1, ymm1, 16
	vpaddq		ymm8, ymm8, ymm1
	vmovdqa		ymm1, ymm8
	vpsllq		ymm8, ymm8, 32
	vpsrlq		ymm1, ymm1, 32
	vpaddq		ymm0, ymm0, ymm8

	; hex x hex1lh
	vmovdqa		ymm8, ymm9
	vmovdqa		ymm12, ymm9
	vmovdqa		ymm13, ymm9
	vpmuldq		ymm8, ymm8, ymm4
	vpmuldq		ymm9, ymm9, ymm5
	vpmuldq		ymm12, ymm12, ymm6
	vpmuldq		ymm13, ymm13, ymm7
	vmovdqa		ymm14, ymm0
	vpsrlq		ymm14, ymm14, 16
	vpand		ymm0, ymm0, ymm2
	vpaddq		ymm8, ymm8, ymm14
	vpsllq		ymm9, ymm9, 16
	vpaddq		ymm8, ymm8, ymm9
	vmovdqa		ymm9, ymm8
	vpand		ymm8, ymm8, ymm3
	vpsrlq		ymm9, ymm9, 32
	vpaddq		ymm9, ymm9, ymm12
	vpsllq		ymm13, ymm13, 16
	vpaddq		ymm9, ymm9, ymm13
	vpsllq		ymm1, ymm1, 16
	vpaddq		ymm1, ymm1, ymm9
	vmovdqa		ymm12, ymm1
	vpsrlq		ymm1, ymm1, 16
	vpand		ymm9, ymm9, ymm2
	vpsllq		ymm9, ymm9, 32
	vpaddq		ymm8, ymm8, ymm9
	vpsllq		ymm8, ymm8, 16
	vpaddq		ymm0, ymm0, ymm8

	; hex x hex1hl
	vmovdqa		ymm8, ymm10
	vmovdqa		ymm9, ymm10
	vmovdqa		ymm12, ymm10
	vpmuldq		ymm8, ymm8, ymm4
	vpmuldq		ymm9, ymm9, ymm5
	vpmuldq		ymm10, ymm10, ymm6
	vpmuldq		ymm12, ymm12, ymm7
	vmovdqa		ymm13, ymm0
	vpand		ymm0, ymm0, ymm3
	vpsrlq		ymm13, ymm13, 32
	vpaddq		ymm8, ymm8, ymm13
	vpsllq		ymm9, ymm9, 16
	vpaddq		ymm8, ymm8, ymm9
	vmovdqa		ymm9, ymm8
	vpand		ymm8, ymm8, ymm3
	vpsllq		ymm8, ymm8, 32
	vpaddq		ymm0, ymm0, ymm8
	vpsrlq		ymm9, ymm9, 32
	vpaddq		ymm9, ymm9, ymm10
	vpaddq		ymm1, ymm1, ymm9
	vpsllq		ymm12, ymm12, 16
	vpaddq		ymm1, ymm1, ymm12

	; hex x hex1hh
	vmovdqa		ymm8, ymm11
	vmovdqa		ymm9, ymm11
	vmovdqa		ymm10, ymm11
	vpmuldq		ymm8, ymm8, ymm4
	vpmuldq		ymm9, ymm9, ymm5
	vpmuldq		ymm10, ymm10, ymm6
	vpmuldq		ymm11, ymm11, ymm7
	vmovdqa		ymm4, ymm0
	vpand		ymm0, ymm0, ymm3
	vpsrlq		ymm4, ymm4, 32
	vpsllq		ymm8, ymm8, 16
	vpaddq		ymm4, ymm4, ymm8
	vmovdqa		ymm8, ymm4
	vpsllq		ymm4, ymm4, 32
	vpaddq		ymm0, ymm0, ymm4
	vpsrlq		ymm8, ymm8, 32
	vpaddq		ymm1, ymm1, ymm8
	vpaddq		ymm1, ymm1, ymm9
	vpsllq		ymm10, ymm10, 16
	vpaddq		ymm1, ymm1, ymm10
	vpsllq		ymm11, ymm11, 32
	vpaddq		ymm1, ymm1, ymm11
	vpunpcklqdq	ymm0, ymm0, ymm1
	vmovdqa		ymmword ptr [r8], ymm0

	jmp			cont
false:
	xor			bl, bl
l1:
	movq		xmm0, qword ptr [rcx + rbx * 8]
	movq		xmm1, qword ptr [rdx + rbx * 8]
	movq		xmm2, qword ptr wordmaxsse
	movq		xmm3, qword ptr dwordmaxsse
	movq		xmm4, xmm0
	movq		xmm5, xmm0
	movq		xmm6, xmm0
	movq		xmm7, xmm0
	movq		xmm8, xmm1
	movq		xmm9, xmm1
	movq		xmm10, xmm1
	movq		xmm11, xmm1
	pand		xmm4, xmm2
	psrlq		xmm5, 16
	pand		xmm5, xmm2
	psrlq		xmm6, 32
	pand		xmm6, xmm2
	psrlq		xmm7, 48
	pand		xmm7, xmm2
	pand		xmm8, xmm2
	psrlq		xmm9, 16
	pand		xmm9, xmm2
	psrlq		xmm10, 32
	pand		xmm10, xmm2
	psrlq		xmm11, 48
	pand		xmm11, xmm2

	; hex x hex1ll
	movq		xmm1, xmm8
	movq		xmm12, xmm8
	movq		xmm13, xmm8
	pmuldq		xmm8, xmm4
	pmuldq		xmm12, xmm5
	pmuldq		xmm13, xmm6
	pmuldq		xmm1, xmm7
	movq		xmm0, xmm8
	psllq		xmm12, 16
	paddq		xmm0, xmm12
	movq		xmm8, xmm0
	psrlq		xmm8, 32
	paddq		xmm8, xmm13
	pand		xmm0, xmm3
	psllq		xmm1, 16
	paddq		xmm8, xmm1
	movq		xmm1, xmm8
	psllq		xmm8, 32
	psrlq		xmm1, 32
	paddq		xmm0, xmm8

	; hex x hex1lh
	movq		xmm8, xmm9
	movq		xmm12, xmm9
	movq		xmm13, xmm9
	pmuldq		xmm8, xmm4
	pmuldq		xmm9, xmm5
	pmuldq		xmm12, xmm6
	pmuldq		xmm13, xmm7
	movq		xmm14, xmm0
	psrlq		xmm14, 16
	pand		xmm0, xmm2
	paddq		xmm8, xmm14
	psllq		xmm9, 16
	paddq		xmm8, xmm9
	movq		xmm9, xmm8
	pand		xmm8, xmm3
	psrlq		xmm9, 32
	paddq		xmm9, xmm12
	psllq		xmm13, 16
	paddq		xmm9, xmm13
	psllq		xmm1, 16
	paddq		xmm1, xmm9
	movq		xmm12, xmm1
	psrlq		xmm1, 16
	pand		xmm9, xmm2
	psllq		xmm9, 32
	paddq		xmm8, xmm9
	psllq		xmm8, 16
	paddq		xmm0, xmm8

	; hex x hex1hl
	movq		xmm8, xmm10
	movq		xmm9, xmm10
	movq		xmm12, xmm10
	pmuldq		xmm8, xmm4
	pmuldq		xmm9, xmm5
	pmuldq		xmm10, xmm6
	pmuldq		xmm12, xmm7
	movq		xmm13, xmm0
	pand		xmm0, xmm3
	psrlq		xmm13, 32
	paddq		xmm8, xmm13
	psllq		xmm9, 16
	paddq		xmm8, xmm9
	movq		xmm9, xmm8
	pand		xmm8, xmm3
	psllq		xmm8, 32
	paddq		xmm0, xmm8
	psrlq		xmm9, 32
	paddq		xmm9, xmm10
	paddq		xmm1, xmm9
	psllq		xmm12, 16
	paddq		xmm1, xmm12

	; hex x hex1hh
	movq		xmm8, xmm11
	movq		xmm9, xmm11
	movq		xmm10, xmm11
	pmuldq		xmm8, xmm4
	pmuldq		xmm9, xmm5
	pmuldq		xmm10, xmm6
	pmuldq		xmm11, xmm7
	movq		xmm4, xmm0
	pand		xmm0, xmm3
	psrlq		xmm4, 32
	psllq		xmm8, 16
	paddq		xmm4, xmm8
	movq		xmm8, xmm4
	psllq		xmm4, 32
	paddq		xmm0, xmm4
	psrlq		xmm8, 32
	paddq		xmm1, xmm8
	paddq		xmm1, xmm9
	psllq		xmm10, 16
	paddq		xmm1, xmm10
	psllq		xmm11, 32
	paddq		xmm1, xmm11
	punpcklqdq	xmm0, xmm1

	mov			eax, ebx
	imul		ax, 2

	movdqa		xmmword ptr [r8 + rax * 8], xmm0

	inc			bl

	cmp			bl, 1
	jle			l1
cont:
	ret
pmulq			endp
pmulqs			proc
	mov			rbp, rcx
	mov			rdi, rdx
	
	lea			r8, res
	call		pmulq
	
	cmp			qword ptr [rcx], 0
	jge			u0

	mov			qword ptr sign, -1
	jmp			c0
u0:
	mov			qword ptr sign, 0
c0:
	cmp			qword ptr 8 [rcx], 0
	jge			u1

	mov			qword ptr 8 [sign], -1
	jmp			c1
u1:
	mov			qword ptr 8 [sign], 0
c1:
	lea			rcx, sign
	lea			r8, res1
	call		pmulq
	
	cmp			qword ptr [rdx], 0
	jge			u2

	mov			qword ptr sign1, -1
	jmp			c2
u2:
	mov			qword ptr sign1, 0
c2:
	cmp			qword ptr 8 [rdx], 0
	jge			u3

	mov			qword ptr 8 [sign1], -1
	jmp			c3
u3:
	mov			qword ptr 8 [sign1], 0
c3:
	mov			rcx, rbp
	lea			rdx, sign1
	lea			r8, res2
	call		pmulq

	lea			rcx, sign
	lea			r8, res3
	call		pmulq

	lea			rax, res
	lea			rsi, res1
	lea			r12, res2
	lea			r13, res3

	cmp			avx2, 0
	jz			false

	vmovdqa		ymm0, ymmword ptr [rax]
	vmovdqa		ymm1, ymmword ptr [rsi]
	vmovdqa		ymm2, ymmword ptr [r12]
	vmovdqa		ymm3, ymmword ptr [r13]
	movq		xmm4, qword ptr dwordmaxsse
	vinsertf128	ymm4, ymm4, xmm4, 1
	movq		xmm5, qword ptr qwordmaxsse
	vinsertf128	ymm5, ymm5, xmm5, 1
	vmovdqa		ymm6, ymm0
	vpsrldq		ymm6, ymm6, 8
	vmovdqa		ymm7, ymm1
	vpand		ymm7, ymm7, ymm5
	vmovdqa		ymm8, ymm6
	vpand		ymm6, ymm6, ymm4
	vpaddq		ymm6, ymm6, ymm7
	vpsrlq		ymm6, ymm6, 32
	vpsrlq		ymm8, ymm8, 32
	vpaddq		ymm6, ymm6, ymm8
	vpsrlq		ymm6, ymm6, 32
	vmovdqa		ymm7, ymm1
	vpslldq		ymm7, ymm7, 8
	vpaddq		ymm0, ymm0, ymm7
	vmovdqa		ymm7, ymm0
	vpsrldq		ymm7, ymm7, 8
	vmovdqa		ymm8, ymm2
	vpand		ymm8, ymm8, ymm5
	vmovdqa		ymm9, ymm7
	vpand		ymm7, ymm7, ymm4
	vpaddq		ymm7, ymm7, ymm8
	vpsrlq		ymm7, ymm7, 32
	vpsrlq		ymm9, ymm9, 32
	vpaddq		ymm7, ymm7, ymm9
	vpsrlq		ymm7, ymm7, 32
	vpaddq		ymm6, ymm6, ymm7
	vmovdqa		ymm14, ymm6
	vmovdqa		ymm7, ymm2
	vpslldq		ymm7, ymm7, 8
	vpaddq		ymm0, ymm0, ymm7
	vpsrldq		ymm1, ymm1, 8
	vpsrldq		ymm2, ymm2, 8
	vmovdqa		ymm8, ymm1
	vmovdqa		ymm9, ymm1
	vmovdqa		ymm10, ymm2
	vmovdqa		ymm11, ymm2
	vmovdqa		ymm12, ymm3
	vmovdqa		ymm13, ymm3
	vpand		ymm8, ymm8, ymm4
	vpsrlq		ymm9, ymm9, 32
	vpand		ymm10, ymm10, ymm4
	vpsrlq		ymm11, ymm11, 32
	vpand		ymm12, ymm12, ymm4
	vpand		ymm13, ymm13, ymm5
	vpsrlq		ymm13, ymm13, 32
	vpaddq		ymm6, ymm6, ymm8
	vpaddq		ymm6, ymm6, ymm10
	vpaddq		ymm6, ymm6, ymm12
	vpsrlq		ymm6, ymm6, 32
	vpaddq		ymm6, ymm6, ymm9
	vpaddq		ymm6, ymm6, ymm11
	vpaddq		ymm6, ymm6, ymm13
	vpsrlq		ymm6, ymm6, 32
	vmovdqa		ymm15, ymm6
	vmovdqa		ymm7, ymm3
	vmovdqa		ymm8, ymm3
	vpsrldq		ymm7, ymm7, 8
	vpand		ymm7, ymm7, ymm4
	vpsrldq		ymm8, ymm8, 12
	vpaddq		ymm6, ymm6, ymm7
	vpsrlq		ymm6, ymm6, 32
	vpaddq		ymm6, ymm6, ymm8
	vpsrlq		ymm6, ymm6, 32
	vpslldq		ymm15, ymm15, 8
	vpaddq		ymm1, ymm1, ymm2
	vpaddq		ymm1, ymm1, ymm3
	vpaddq		ymm1, ymm1, ymm14
	vpaddq		ymm1, ymm1, ymm15
	vmovdqa		ymmword ptr [rax], ymm0

	jmp			c4
false:
	xor			bl, bl
l1:
	movdqa		xmm0, xmmword ptr [rax + rbx]
	movdqa		xmm1, xmmword ptr [rsi + rbx]
	movdqa		xmm2, xmmword ptr [r12 + rbx]
	movdqa		xmm3, xmmword ptr [r13 + rbx]
	movq		xmm4, qword ptr dwordmaxsse
	movq		xmm5, qword ptr qwordmaxsse
	movdqa		xmm6, xmm0
	psrldq		xmm6, 8
	movdqa		xmm7, xmm1
	pand		xmm7, xmm5
	movdqa		xmm8, xmm6
	pand		xmm6, xmm4
	paddq		xmm6, xmm7
	psrlq		xmm6, 32
	psrlq		xmm8, 32
	paddq		xmm6, xmm8
	psrlq		xmm6, 32
	movdqa		xmm7, xmm1
	pslldq		xmm7, 8
	paddq		xmm0, xmm7
	movdqa		xmm7, xmm0
	psrldq		xmm7, 8
	movdqa		xmm8, xmm2
	pand		xmm8, xmm5
	movdqa		xmm9, xmm7
	pand		xmm7, xmm4
	paddq		xmm7, xmm8
	psrlq		xmm7, 32
	psrlq		xmm9, 32
	paddq		xmm7, xmm9
	psrlq		xmm7, 32
	paddq		xmm6, xmm7
	movdqa		xmm14, xmm6
	movdqa		xmm7, xmm2
	pslldq		xmm7, 8
	paddq		xmm0, xmm7
	psrldq		xmm1, 8
	psrldq		xmm2, 8
	movdqa		xmm8, xmm1
	movdqa		xmm9, xmm1
	movdqa		xmm10, xmm2
	movdqa		xmm11, xmm2
	movdqa		xmm12, xmm3
	movdqa		xmm13, xmm3
	pand		xmm8, xmm4
	psrlq		xmm9, 32
	pand		xmm10, xmm4
	psrlq		xmm11, 32
	pand		xmm12, xmm4
	pand		xmm13, xmm5
	psrlq		xmm13, 32
	paddq		xmm6, xmm8
	paddq		xmm6, xmm10
	paddq		xmm6, xmm12
	psrlq		xmm6, 32
	paddq		xmm6, xmm9
	paddq		xmm6, xmm11
	paddq		xmm6, xmm13
	psrlq		xmm6, 32
	movdqa		xmm15, xmm6
	movdqa		xmm7, xmm3
	movdqa		xmm8, xmm3
	psrldq		xmm7, 8
	pand		xmm7, xmm4
	psrldq		xmm8, 12
	paddq		xmm6, xmm7
	psrlq		xmm6, 32
	paddq		xmm6, xmm8
	psrlq		xmm6, 32
	pslldq		xmm15, 8
	paddq		xmm1, xmm2
	paddq		xmm1, xmm3
	paddq		xmm1, xmm14
	paddq		xmm1, xmm15
	movdqa		xmmword ptr [rax + rbx], xmm0

	add			bl, 16

	cmp			bl, 16
	jle			l1
c4:
	ret
pmulqs			endp
pad_with_zeros	proc
	sub		rsp, 40

	mov		src, rcx
	mov		target_length, dl
	call	strlen
	mov		current_length, al

	movzx	ecx, target_length
	sub		cl, al
	mov		padding, cl

	cmp		padding, 0
	jle		f1

	std
	mov		rsi, src
	mov		al, target_length
	sub		al, current_length
	inc		al
	lea		rdi, [rsi + rax]
	lea		rsi, [rsi + 1]
	mov		cl, current_length
	rep		movsb

	cld
	lea		rsi, zero
	mov		rdi, src
	mov		cl, padding
	rep		movsb
f1:
	add		rsp, 40

	ret
pad_with_zeros	endp
addf			proc
	sub		rsp, 72

	mov		qword ptr 32 [rsp], rcx
	mov		qword ptr 40 [rsp], rdx
	mov		sizev, r8b
	call	strlen
	mov		len, al
	dec		al
	mov		byte ptr 48 [rsp], al

	mov		rcx, qword ptr 40 [rsp]
	call	strlen
	mov		len1, al

	cmp		al, sizev
	jge		f1

	mov		rcx, qword ptr 40 [rsp]
	mov		dl, sizev
	call	pad_with_zeros
f1:
	mov		rcx, qword ptr 40 [rsp]
	call	strlen
	mov		len1, al
	dec		al
	mov		byte ptr 49 [rsp], al

	lea		rax, sum
	mov		qword ptr 56 [rsp], rax
l1:
	movzx	eax, carry
	mov		byte ptr 56 [rsp], al

	cmp		byte ptr 48 [rsp], 0
	jl		f2

	movzx	ecx, byte ptr 48 [rsp]
	mov		rdx, qword ptr 32 [rsp]
	add		al, byte ptr [rdx + rcx]
	mov		byte ptr 56 [rsp], al
	sub		byte ptr 56 [rsp], '0'
	dec		byte ptr 48 [rsp]
f2:
	cmp		byte ptr 49 [rsp], 0
	jl		f3

	mov		al, byte ptr 56 [rsp]
	mov		cl, byte ptr 49 [rsp]
	mov		rdx, qword ptr 40 [rsp]
	add		al, byte ptr [rdx + rcx]
	mov		byte ptr 56 [rsp], al
	sub		byte ptr 56 [rsp], '0'
f3:
	xor		ah, ah
	mov		al, byte ptr 56 [rsp]
	mov		cl, 10
	div		cl
	mov		carry, al

	cmp		byte ptr 49 [rsp], 0
	jl		f4

	movzx	eax, ah
	add		al, '0'
	mov		cl, byte ptr 49 [rsp]
	mov		rdx, qword ptr 40 [rsp]
	mov		byte ptr [rdx + rcx], al
	dec		byte ptr 49 [rsp]
f4:
	mov		al, byte ptr 49 [rsp]
	cmp		al, 0
	jge		l1
	cmp		byte ptr 48 [rsp], 0
	jge		l1
	cmp		carry, 0
	jnz		l1

	add		rsp, 72
	
	ret
addf			endp
subf			proc
	sub		rsp, 72

	mov		negv, 0
	mov		qword ptr 32 [rsp], rcx
	mov		sizesrc, dl
	mov		qword ptr 40 [rsp], r8
	mov		sizedest, r9b
	call	strlen
	mov		len2, al
	dec		al
	mov		byte ptr 48 [rsp], al

	mov		rcx, qword ptr 40 [rsp]
	call	strlen

	cmp		len2, al
	jbe		f1

	mov		rcx, qword ptr 40 [rsp]
	movzx	edx, len2
	call	pad_with_zeros
f1:
	mov		rcx, qword ptr 40 [rsp]
	call	strlen
	mov		len3, al
	dec		al
	mov		byte ptr 49 [rsp], al

	movzx	ecx, sizesrc
	call	malloc
	mov		swap, rax

	test	rax, rax
	jnz		f2

	mov		ecx, 1
	call	ExitProcess
f2:
	movzx	ecx, sizesrc
	call	malloc
	mov		temp, rax

	test	rax, rax
	jnz		f3

	mov		ecx, 1
	call	ExitProcess
f3:
	movzx	ecx, sizedest
	call	malloc
	mov		temp1, rax

	test	rax, rax
	jnz		f4

	mov		ecx, 1
	call	ExitProcess
f4:
	mov		rsi, qword ptr 32 [rsp]
	mov		rdi, temp
	movzx	ecx, sizesrc
	rep		movsb

	mov		rsi, qword ptr 40 [rsp]
	mov		rdi, temp1
	mov		cl, sizedest
	rep		movsb

	mov		rsi, qword ptr 32 [rsp]
	mov		rdi, qword ptr 40 [rsp]
	mov		cl, sizesrc
	repe	cmpsb
	jbe		l1

	mov		negv, 1
	
	mov		rsi, temp
	mov		rdi, swap
	mov		cl, sizesrc
	rep		movsb

	mov		rsi, temp1
	mov		rdi, temp
	mov		cl, sizesrc
	rep		movsb

	mov		rsi, swap
	mov		rdi, temp1
	mov		cl, sizedest
	rep		movsb
l1:
	cmp		byte ptr 49 [rsp], 0
	js		f5

	mov		rax, temp1
	mov		cl, byte ptr 49 [rsp]
	mov		dl, byte ptr [rax + rcx]
	sub		dl, '0'
	mov		byte ptr 50 [rsp], dl
	jmp		c1
f5:
	mov		byte ptr 50 [rsp], 0
c1:
	cmp		byte ptr 48 [rsp], 0
	js		f6

	mov		rax, temp
	mov		cl, byte ptr 48 [rsp]
	mov		dl, byte ptr [rax + rcx]
	sub		dl, '0'
	mov		byte ptr 51 [rsp], dl
	jmp		c2
f6:
	mov		byte ptr 51 [rsp], 0
c2:
	movzx	eax, borrow
	sub		byte ptr 50 [rsp], al

	mov		al, byte ptr 50 [rsp]
	cmp		al, byte ptr 51 [rsp]
	jge		f7

	add		byte ptr 50 [rsp], 10
	mov		borrow, 1
	jmp		c3
f7:
	mov		borrow, 0
c3:
	mov		rax, temp1
	mov		cl, byte ptr 49 [rsp]
	mov		dl, byte ptr 50 [rsp]
	sub		dl, byte ptr 51 [rsp]
	add		dl, '0'
	mov		byte ptr [rax + rcx], dl
	dec		byte ptr 49 [rsp]
	dec		byte ptr 48 [rsp]

	cmp		byte ptr 49 [rsp], 0
	jge		l1
	cmp		byte ptr 48 [rsp], 0
	jge		l1

	mov		rax, temp1
	xor		cl, cl
l2:
	cmp		byte ptr [rax + rcx], '0'
	jne		c4

	inc		cl
	
	jmp		l2
c4:
	cmp		negv, 0
	jz		f8

	mov		byte ptr [rax + rcx - 1], '-'
f8:
	mov		rsi, rax
	mov		rdi, qword ptr 40 [rsp]
	mov		cl, sizedest
	rep		movsb

	mov		rcx, swap
	call	free

	mov		rcx, temp
	call	free

	mov		rcx, temp1
	call	free

	add		rsp, 72

	ret
subf			endp
cvti2s			proc
	sub		rsp, 40

	mov		byte ptr 32 [rsp], r12b
	mov		r12, rcx
	mov		r13, rdx
	mov		r14, r8
	mov		sizev1, r9b

	mov		rcx, r8
	mov		edx, r9d
	lea		r8, num
	mov		r9, r13
	call	sprintf_s

	mov		rcx, r14
	call	strlen
	mov		len4, al

	mov		r15, r12
	and		r15, 0fh
	jz		f1
l1:
	lea		rcx, hex
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l1
f1:
	mov		r15, r12
	and		r15, 0ffh
	shr		r15, 4
	jz		f2
l2:
	lea		rcx, hex1
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l2
f2:
	mov		r15, r12
	and		r15, 0fffh
	shr		r15, 8
	jz		f3
l3:
	lea		rcx, hex2
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l3
f3:
	mov		r15, r12
	and		r15, 0ffffh
	shr		r15, 12
	jz		f4
l4:
	lea		rcx, hex3
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l4
f4:
	mov		r15, r12
	and		r15, 0fffffh
	shr		r15, 16
	jz		f5
l5:
	lea		rcx, hex4
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l5
f5:
	mov		r15, r12
	and		r15, 0ffffffh
	shr		r15, 20
	jz		f6
l6:
	lea		rcx, hex5
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l6
f6:
	mov		r15, r12
	and		r15, 0fffffffh
	shr		r15, 24
	jz		f7
l7:
	lea		rcx, hex6
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l7
f7:
	mov		r15, r12
	mov		rax, 0ffffffffh
	and		r15, rax
	shr		r15, 28
	jz		f8
l8:
	lea		rcx, hex7
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l8
f8:
	mov		r15, r12
	mov		rax, 0fffffffffh
	and		r15, rax
	shr		r15, 32
	jz		f9
l9:
	lea		rcx, hex8
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l9
f9:
	mov		r15, r12
	mov		rax, 0ffffffffffh
	and		r15, rax
	shr		r15, 36
	jz		f10
l10:
	lea		rcx, hex9
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l10
f10:
	mov		r15, r12
	mov		rax, 0fffffffffffh
	and		r15, rax
	shr		r15, 40
	jz		f11
l11:
	lea		rcx, hex10
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l11
f11:
	mov		r15, r12
	mov		rax, 0ffffffffffffh
	and		r15, rax
	shr		r15, 44
	jz		f12
l12:
	lea		rcx, hex11
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l12
f12:
	mov		r15, r12
	mov		rax, 0fffffffffffffh
	and		r15, rax
	shr		r15, 48
	jz		f13
l13:
	lea		rcx, hex12
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l13
f13:
	mov		r15, r12
	mov		rax, 0ffffffffffffffh
	and		r15, rax
	shr		r15, 52
	jz		f14
l14:
	lea		rcx, hex13
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l14
f14:
	mov		r15, r12
	mov		rax, 0fffffffffffffffh
	and		r15, rax
	shr		r15, 56
	jz		f15
l15:
	lea		rcx, hex14
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l15
f15:
	mov		r15, r12
	mov		rax, -1
	and		r15, rax
	shr		r15, 60
	jz		f16
l16:
	lea		rcx, hex15
	mov		rdx, r14
	mov		r8b, len4
	call	addf

	dec		r15b
	jnz		l16
f16:
	cmp		byte ptr 32 [rsp], 0
	jz		f17
	test	r12, r12
	jns		f17

	lea		rcx, hex16
	mov		dl, lengthof hex16
	mov		r8, r14
	movzx	r9d, sizev1
	call	subf
f17:
	xor		r12d, r12d
l17:
	cmp		byte ptr [r14 + r12], '0'
	jnz		c1

	inc		r12b
	jmp		l17
c1:
	cmp		byte ptr [r14 + r12], 0
	jnz		f18

	cld
	lea		rsi, zero
	mov		rdi, r14
	movzx	ecx, sizev1
	rep		movsb
	jmp		c2
f18:
	mov		rdi, r14
	lea		rsi, [rdi + r12]
	movzx	ecx, len4
	sub		cl, r12b
	inc		cl
	rep		movsb
c2:
	add		rsp, 40

	ret
cvti2s			endp
divf			proc
	sub			rsp, 40

	mov			rbx, rcx
	mov			rbp, rdx
	mov			r12, r8
	mov			sign2, r9b
	
	mov			rsi, rcx
	lea			rdi, temp2
	mov			ecx, 2
	rep			movsq

	mov			qword ptr [r12], 0
	mov			qword ptr 8 [r12], 0
	movdqa		xmm0, xmmword ptr [r12]

	cmp			qword ptr [rbp], 0
	jz			error
	cmp			qword ptr 8 [rbp], 0
	jz			error
	cmp			sign2, 0
	jz			u1
	cmp			qword ptr temp2, 0
	jns			u2

	mov			byte ptr sign3, 1
	jmp			c1
u2:
	mov			byte ptr sign3, 0
c1:
	cmp			qword ptr 8 [temp2], 0
	jns			u3

	mov			byte ptr 1 [sign3], 1
	jmp			c2
u3:
	mov			byte ptr 1 [sign3], 0
c2:
	cmp			qword ptr [rbp], 0
	jns			u4

	mov			byte ptr sign4, 1
	jmp			c3
u4:
	mov			byte ptr sign4, 0
c3:
	cmp			qword ptr 8 [rbp], 0
	jns			u5

	mov			byte ptr 1 [sign4], 1
	jmp			c4
u5:
	mov			byte ptr 1 [sign4], 0
c4:
	mov			al, byte ptr sign3
	cmp			al, byte ptr sign4
	jz			e1
	js			s1

	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]

	mov			al, byte ptr 8 [sign3]
	cmp			al, byte ptr 8 [sign4]
	jz			e2
	js			s2

	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l1:
	movdqa		xmmword ptr temp2, xmm1

	cmp			qword ptr temp2, 0
	jge			f1
	cmp			qword ptr 8 [temp2], 0
	jge			f2

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l1
f1:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jge			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l1
f2:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jge			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l1
e1:
	mov			al, byte ptr 8 [sign3]
	cmp			al, byte ptr 8 [sign4]
	js			s3
	jns			u7

	cmp			byte ptr sign3, 0
	jz			u8
	cmp			byte ptr 8 [sign3], 0
	jz			u9

	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l9:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			f18
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			f19

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l9
f18:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l9
f19:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l9
u8:
	cmp			byte ptr 8 [sign3], 0
	jz			u1

	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l10:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jl			f20
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			f21

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l10
f20:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l10
f21:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jl			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l10
u9:
	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l12:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			f24
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jl			f25

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l12
f24:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jl			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l12
f25:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l12
s3:
	neg			qword ptr 8 [rbp]
	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			rax, -1
	movq		xmm3, rax
	mov			eax, 1
	pinsrq		xmm3, rax, 1

	cmp			byte ptr sign3, 0
	jz			l8
l7:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			f14
	cmp			qword ptr 8 [temp2], 0
	jle			f15

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l7
f14:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jle			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l7
f15:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l7
l8:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jl			f16
	cmp			qword ptr 8 [temp2], 0
	jle			f17

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l8
f16:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jle			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l8
f17:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jl			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l8
u7:
	neg			qword ptr 8 [rbp]
	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			rax, -1
	movq		xmm3, rax
	mov			eax, 1
	pinsrq		xmm3, rax, 1

	cmp			byte ptr sign3, 0
	jz			l4
l3:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			f6
	cmp			qword ptr 8 [temp2], 0
	jge			f7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l3
f6:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jge			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l3
f7:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jg			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l3
l4:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jl			f8
	cmp			qword ptr 8 [temp2], 0
	jge			f9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l4
f8:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jge			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l4
f9:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jl			c7

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l4
s1:
	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]

	mov			al, byte ptr 8 [sign3]
	cmp			al, byte ptr 8 [sign4]
	jz			e3
	jns			u6

	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l5:
	movdqa		xmmword ptr temp2, xmm1

	cmp			qword ptr temp2, 0
	jle			f10
	cmp			qword ptr 8 [temp2], 0
	jle			f11

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l5
f10:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jle			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l5
f11:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jle			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l5
e3:
	neg			qword ptr [rbp]
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			rax, 1
	movq		xmm3, rax
	mov			eax, -1
	pinsrq		xmm3, rax, 1

	cmp			byte ptr sign4, 0
	jz			l16
l15:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	cmp			qword ptr temp2, 0
	jle			f30
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			f31

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l15
f30:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l15
f31:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jle			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l15
l16:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	cmp			qword ptr temp2, 0
	jle			f32
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jl			f33

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l16
f32:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jl			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l16
f33:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jle			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l16
u6:
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l2:
	movdqa		xmmword ptr temp2, xmm1

	cmp			qword ptr temp2, 0
	jle			f4
	cmp			qword ptr 8 [temp2], 0
	jge			f5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l2
f4:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jge			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l2
f5:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jle			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l2
e2:
	neg			qword ptr [rbp]
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			rax, 1
	movq		xmm3, rax
	mov			eax, -1
	pinsrq		xmm3, rax, 1

	cmp			byte ptr sign4, 0
	jz			l14
l13:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	cmp			qword ptr temp2, 0
	jge			f26
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			f27

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l13
f26:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jg			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l13
f27:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jge			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l13
l14:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	cmp			qword ptr temp2, 0
	jge			f28
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jl			f29

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l14
f28:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jl			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l14
f29:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jge			c8

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l14
s2:
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l6:
	movdqa		xmmword ptr temp2, xmm1

	cmp			qword ptr temp2, 0
	jge			f12
	cmp			qword ptr 8 [temp2], 0
	jle			f13

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l6
f12:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	cmp			qword ptr 8 [temp2], 0
	jle			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l6
f13:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	cmp			qword ptr temp2, 0
	jle			c5

	paddq		xmm1, xmm2
	psubq		xmm0, xmm3

	jmp			l6
u1:
	movq		xmm3, qword ptr temp2
	movq		xmm4, qword ptr [rbp]
	movq		xmm1, qword ptr 8 [temp2]
	movq		xmm2, qword ptr 8 [rbp]
	punpcklqdq	xmm1, xmm3
	punpcklqdq	xmm2, xmm4
	mov			eax, 1
	movq		xmm3, rax
	punpcklqdq	xmm3, xmm3
l11:
	movdqa		xmmword ptr temp2, xmm1
	movdqa		xmmword ptr [rbp], xmm2

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jb			f22
	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jb			f23

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l11
f22:
	xor			eax, eax
	pinsrq		xmm2, rax, 1
	pinsrq		xmm3, rax, 1

	mov			rax, qword ptr 8 [temp2]
	cmp			rax, qword ptr 8 [rbp]
	jb			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l11
f23:
	xor			eax, eax
	pinsrq		xmm2, rax, 0
	pinsrq		xmm3, rax, 0

	mov			rax, qword ptr temp2
	cmp			rax, qword ptr [rbp]
	jb			c9

	psubq		xmm1, xmm2
	paddq		xmm0, xmm3

	jmp			l11
c5:
	movdqa	xmmword ptr [r12], xmm0

	cmp		qword ptr [r12], 0
	jz		f3

	inc		qword ptr [r12]

	cmp		qword ptr 8 [r12], 0
	jz		c6

	inc		qword ptr 8 [r12]

	jmp		c6
f3:
	cmp		qword ptr 8 [r12], 0
	jz		c6

	inc		qword ptr 8 [r12]

	jmp		c6
c7:
	movdqa	xmmword ptr [r12], xmm0

	cmp		qword ptr 8 [r12], 0
	jz		c6

	inc		qword ptr 8 [r12]

	jmp		c6
c8:
	movdqa	xmmword ptr [r12], xmm0

	cmp		qword ptr [r12], 0
	jz		c6

	inc		qword ptr [r12]

	jmp		c6
c9:
	movdqa	xmmword ptr [r12], xmm0
c6:
	add		rsp, 40

	ret
error:
	mov		ecx, 1
	call	ExitProcess
divf			endp
end