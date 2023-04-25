.global main

.text
main:
	mov r0, #1
	ldr r1, =message
	ldr r2, =len

	mov r7, #4
	swi 0

	mov r7, #1
	swi 0

.data
message:
	.asciz "Binary search!\n"
	len =.-message
