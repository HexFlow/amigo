.global main

.bss

.text


	# LABL;0-main
main:

	# NEWFUNC
	push %rbp
	mov %rsp, %rbp

	# Variable of size 16 and name 3-2-0-a1 will be at -16(%rbp)
	# Variable of size 16 and name 3-2-0-a2 will be at -32(%rbp)
	# Variable of size 16 and name 3-2-0-a3 will be at -48(%rbp)
	# Variable of size 16 and name 3-2-0-a4 will be at -64(%rbp)
	# Variable *-tmp-Pointer-ll-0 will be at (a249d58a9)
	# Variable *-tmp-Pointer-ll-0 will be at (a249d58a9)
	# Variable *-tmp-Pointer-ll-1 will be at (a12823f95)
	# Variable *-tmp-Pointer-ll-1 will be at (a12823f95)
	# Variable *-tmp-Pointer-ll-2 will be at (a57c192df)
	# Variable *-tmp-Pointer-ll-2 will be at (a57c192df)
	# Variable *-tmp-Pointer-ll-3 will be at (abd3096e2)
	# Variable of size 8 and name 3-2-0-head will be at -72(%rbp)
	# Variable *-tmp-Pointer-ll-3 will be at (abd3096e2)
	# Variable of size 8 and name 3-2-0-found will be at -80(%rbp)
	# Variable *-tmp-Pointer-ll-5 will be at (ae5f8a0e3)
	# Variable *-tmp-Pointer-ll-5 will be at (ae5f8a0e3)
	# Variable *-tmp-Pointer-ll-5 will be at (ae5f8a0e3)
	# Variable *-tmp-Pointer-ll-5 will be at (ae5f8a0e3)
	# Variable *-tmp-bool-4 will be at (a9372a951)
	# Variable *-tmp-bool-4 will be at (a9372a951)
	# Variable *-tmp-int-7 will be at (afc6cdbdc)
	# Variable *-tmp-int-7 will be at (afc6cdbdc)
	# Variable *-tmp-int-7 will be at (afc6cdbdc)
	# Variable *-tmp-int-7 will be at (afc6cdbdc)
	# Variable *-tmp-bool-6 will be at (a250765d1)
	# Variable *-tmp-bool-6 will be at (a250765d1)
	# Variable *-tmp-int-8 will be at (a3f4e375c)
	# Variable *-tmp-int-9 will be at (a3a1b3795)
	sub $80, %rsp

	# DECL;3-2-0-a1

	# DECL;3-2-0-a2

	# DECL;3-2-0-a3

	# DECL;3-2-0-a4

	# STOR;1;3-2-0-a1.a
	lea	-16(%rbp),	%r15
	lea	8(%r15),	%r15
	movq	$1, (%r15)

	# STOR;2;3-2-0-a2.a
	lea	-32(%rbp),	%r14
	lea	8(%r14),	%r14
	movq	$2, (%r14)

	# STOR;3;3-2-0-a3.a
	lea	-48(%rbp),	%r13
	lea	8(%r13),	%r13
	movq	$3, (%r13)

	# STOR;4;3-2-0-a4.a
	lea	-64(%rbp),	%r12
	lea	8(%r12),	%r12
	movq	$4, (%r12)

	# ADDR;3-2-0-a2;*-tmp-Pointer-ll-0
	# Swapping out %r11 for *-tmp-Pointer-ll-0
	mov	(a249d58a9), %r11
	lea -32(%rbp), 	%r11

	# STOR;*-tmp-Pointer-ll-0;3-2-0-a1.next
	lea	-16(%rbp),	%r10
	lea	0(%r10),	%r10
	movq	%r11, (%r10)

	# ADDR;3-2-0-a3;*-tmp-Pointer-ll-1
	# Swapping out %rbx for *-tmp-Pointer-ll-1
	mov	(a12823f95), %rbx
	lea -48(%rbp), 	%rbx

	# STOR;*-tmp-Pointer-ll-1;3-2-0-a2.next
	lea	-32(%rbp),	%r15
	lea	0(%r15),	%r15
	movq	%rbx, (%r15)

	# ADDR;3-2-0-a4;*-tmp-Pointer-ll-2
	# Swapping out %r14 for *-tmp-Pointer-ll-2
	mov	(a57c192df), %r14
	lea -64(%rbp), 	%r14

	# STOR;*-tmp-Pointer-ll-2;3-2-0-a3.next
	lea	-48(%rbp),	%r13
	lea	0(%r13),	%r13
	movq	%r14, (%r13)

	# STOR;$0;3-2-0-a4.next
	lea	-64(%rbp),	%r12
	lea	0(%r12),	%r12
	movq	$0, (%r12)

	# ADDR;3-2-0-a1;*-tmp-Pointer-ll-3
	mov %r11,	(a249d58a9)
	# Swapping out %r11 for *-tmp-Pointer-ll-3
	mov	(abd3096e2), %r11
	lea -16(%rbp), 	%r11

	# DECL;3-2-0-head

	# STOR;*-tmp-Pointer-ll-3;3-2-0-head
	# Swapping out %r10 for 3-2-0-head
	mov	-72(%rbp), %r10
	mov 	%r11,	%r10

	# DECL;3-2-0-found

	# STOR;$0;3-2-0-found
	mov %rbx,	(a12823f95)
	# Swapping out %rbx for 3-2-0-found
	mov	-80(%rbp), %rbx
	mov 	$0,	%rbx

	# LABL;label5
	mov %rbx,	-80(%rbp)
	mov %r10,	-72(%rbp)
	mov %r11,	(abd3096e2)
	mov %r14,	(a57c192df)
label5:

	# STOR;3-2-0-head;*-tmp-Pointer-ll-5
	# Swapping out %r15 for 3-2-0-head
	mov	-72(%rbp), %r15
	# Swapping out %r14 for *-tmp-Pointer-ll-5
	mov	(ae5f8a0e3), %r14
	mov 	%r15,	%r14

	# CMP;$0;*-tmp-Pointer-ll-5
	cmp 	$0,	%r14

	# EQ;*-tmp-Pointer-ll-5
	mov $0,%r14
	sete %r14b

	# STOR;*-tmp-Pointer-ll-5;*-tmp-bool-4
	# Swapping out %r13 for *-tmp-bool-4
	mov	(a9372a951), %r13
	mov 	%r14,	%r13

	# JEQZ;*-tmp-bool-4;label3
	cmp $0, 	%r13
	mov %r13,	(a9372a951)
	mov %r14,	(ae5f8a0e3)
	mov %r15,	-72(%rbp)
	je	label3

	# JMP;label1
	jmp	label1

	# LABL;label3
label3:

	# STOR;3-2-0-head.a;*-tmp-int-7
#{'%rbx': [None, 0], '%r10': [None, 0], '%r11': [None, 0], '%r12': [None, 0], '%r13': [None, 0], '%r14': [None, 0], '%r15': [None, 0]}
# HERE-72(%rbp)
	mov	-72(%rbp),	%r15
	lea	8(%r15),	%r15
	mov	(%r15), %r15
	# Swapping out %r14 for *-tmp-int-7
	mov	(afc6cdbdc), %r14
	mov %r15,	%r14

	# CMP;3;*-tmp-int-7
	cmp 	$3 ,	%r14

	# EQ;*-tmp-int-7
	mov $0,%r14
	sete %r14b

	# STOR;*-tmp-int-7;*-tmp-bool-6
	# Swapping out %r13 for *-tmp-bool-6
	mov	(a250765d1), %r13
	mov 	%r14,	%r13

	# JEQZ;*-tmp-bool-6;label4
	cmp $0, 	%r13
	mov %r13,	(a250765d1)
	mov %r14,	(afc6cdbdc)
	je	label4

	# STOR;$1;3-2-0-found
	# Swapping out %r15 for 3-2-0-found
	mov	-80(%rbp), %r15
	mov 	$1,	%r15

	# JMP;label1
	mov %r15,	-80(%rbp)
	jmp	label1

	# LABL;label4
label4:

	# STOR;3-2-0-head.next;3-2-0-head
#{'%rbx': [None, 0], '%r10': [None, 0], '%r11': [None, 0], '%r12': [None, 0], '%r13': [None, 0], '%r14': [None, 0], '%r15': [None, 0]}
# HERE-72(%rbp)
	mov	-72(%rbp),	%r15
	lea	0(%r15),	%r15
	mov	(%r15), %r15
	# Swapping out %r14 for 3-2-0-head
	mov	-72(%rbp), %r14
	mov %r15,	%r14

	# LABL;label2
	mov %r14,	-72(%rbp)
label2:

	# JMP;label5
	jmp	label5

	# LABL;label1
label1:

	# JEQZ;3-2-0-found;label6
	# Swapping out %r15 for 3-2-0-found
	mov	-80(%rbp), %r15
	cmp $0, 	%r15
	mov %r15,	-80(%rbp)
	je	label6

	# PUSHARG;0;"Found\n"
# WB without flush
#{'%rbx': [None, 0], '%r10': [None, 0], '%r11': [None, 0], '%r12': [None, 0], '%r13': [None, 0], '%r14': [None, 0], '%r15': [None, 0]}
	mov 	$nbmfhkav,	%rdi

	# CALL;ffi.printf
	xor	%eax,	%eax
	call	printf
	push %rax

	# POP;*-tmp-int-8
	# Swapping out %r15 for *-tmp-int-8
	mov	(a3f4e375c), %r15
	pop	%r15

	# JMP;label7
	mov %r15,	(a3f4e375c)
	jmp	label7

	# LABL;label6
label6:

	# PUSHARG;0;"Not found\n"
# WB without flush
#{'%rbx': [None, 0], '%r10': [None, 0], '%r11': [None, 0], '%r12': [None, 0], '%r13': [None, 0], '%r14': [None, 0], '%r15': [None, 0]}
	mov 	$skegtazy,	%rdi

	# CALL;ffi.printf
	xor	%eax,	%eax
	call	printf
	push %rax

	# POP;*-tmp-int-9
	# Swapping out %r15 for *-tmp-int-9
	mov	(a3a1b3795), %r15
	pop	%r15

	# LABL;label7
	mov %r15,	(a3a1b3795)
label7:

	# NEWFUNCEND

	mov %rbp, %rsp
	pop %rbp
	ret

.data
nbmfhkav:
	.asciz	"Found\n"
skegtazy:
	.asciz	"Not found\n"
.bss
a249d58a9:
	.space 8
a12823f95:
	.space 8
a57c192df:
	.space 8
abd3096e2:
	.space 8
ae5f8a0e3:
	.space 8
a9372a951:
	.space 8
afc6cdbdc:
	.space 8
a250765d1:
	.space 8
a3f4e375c:
	.space 8
a3a1b3795:
	.space 8
