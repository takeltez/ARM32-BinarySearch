.text
d_in:
	push {lr}

	ldr r0, =info_msg

	bl printf

	ldr r0, =size_msg

	bl printf

	sub sp, sp, #4

	ldr r0, =scanf_input
	mov r1, sp

	bl scanf

	ldr r0, =nl_msg

	bl printf

	mov r8, sp
	mov r0, #4
	ldr r4, [sp]

	cmp r4, #0

	ble _size_err

	mul r5, r4, r0

	sub sp, sp, r5
	sub sp, sp, #4

	mov r7, r4
	mov r6, sp

_d_in_loop:
	sub r4, r4, #1
	cmp r4, #0

	blt _d_in_loop_exit

	ldr r0, =arr_msg

	sub r1, r7, r4
	sub r1, r1, #1

	bl printf

	ldr r0, =scanf_input
	mov r1, r6

	bl scanf

	add r6, #4

	bal _d_in_loop

_d_in_loop_exit:
	ldr r0, =elem_msg

	bl printf

	ldr r0, =scanf_input
	mov r1, r6

	bl scanf

	add sp, sp, r5
	add sp, sp, #4

	b _d_in_exit

_size_err:
	ldr r0, =wr_size_msg

	bl printf

	mov r7, #1
	swi 0

_d_in_exit:
	add sp, sp, #4

	pop {lr}
	bx lr

d_out:
	push {lr}

	cmp r3, #-1

	beq _no_elem

	ldr r0, =is_elem_msg
	mov r1, r3

	bl printf

	b _d_out_exit

_no_elem:
	ldr r0, =no_elem_msg
	mov r1, r2

	bl printf

_d_out_exit:
	pop {lr}
	bx lr

.data
info_msg:
	.asciz "Array must be sorted in ascending order!\n\n"
size_msg:
	.asciz "Array size: "
arr_msg:
	.asciz "Array[%d]: "
elem_msg:
	.asciz "\nFound element: "
is_elem_msg:
	.asciz "\nArray[%d] = %d\n"
no_elem_msg:
	.asciz "\nElement %d not found\n"
wr_size_msg:
	.asciz "\nSize must be a positive number!\n"
nl_msg:
	.asciz "\n"
scanf_input:
	.asciz "%d"
