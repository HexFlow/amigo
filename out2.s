.global main
.bss
.text
main:
	push %rbp
	mov %rsp, %rbp
	sub $8, %rsp
	mov	-8(%rbp), %r15
	mov 	$0 ,	%r15
	mov %r15,	-8(%rbp)
label5:
	mov	-8(%rbp), %r15
	mov	(af54f35b7), %r14
	mov 	%r15,	%r14
	cmp 	$10 ,	%r14
	mov $0,%r14
	setl %r14b
	mov	(a4a8e7e28), %r13
	mov 	%r14,	%r13
	cmp 	$0 ,	%r13
	mov %r13,	(a4a8e7e28)
	mov %r14,	(af54f35b7)
	mov %r15,	-8(%rbp)
	je	label6
	mov	-8(%rbp), %r15
	mov	(a1f9fffac), %r14
	mov 	%r15,	%r14
	cmp 	$5 ,	%r14
	mov $0,%r14
	sete %r14b
	mov	(a0376a349), %r13
	mov 	%r14,	%r13
	cmp $0, 	%r13
	mov %r13,	(a0376a349)
	mov %r14,	(a1f9fffac)
	mov %r15,	-8(%rbp)
	je	label2
	jmp	label1
	jmp	label4
	jmp	label2
label4:
label2:
	mov	-8(%rbp), %r15
	add	$1 ,	%r15
	mov %r15,	-8(%rbp)
	jmp	label5
label1:
label6:
	mov %rbp, %rsp
	pop %rbp
	ret
.data
.bss
af54f35b7:
	.space 8
a4a8e7e28:
	.space 8
a1f9fffac:
	.space 8
a0376a349:
	.space 8