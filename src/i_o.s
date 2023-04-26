.text
d_in:
	mov r0, #1
	ldr r1, =message
	ldr r2, =len

	mov r7, #4
	swi 0

	bx lr

.data
message:
	.asciz "Binary search\n"
	len =.-message

