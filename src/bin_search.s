.text
b_srch:
	mov r3, #4
	add r4, r1, #2

	mul r4, r4, r3
	sub r4, r8, r4

_b_srch_loop:
	cmp r0, r1

	bgt _not_found

	sub r5, r1, r0
	add r5, r0, r5, lsr #1

	mul r6, r5, r3
	add r6, r4, r6

	ldr r6, [r6]

	cmp r6, r2

	beq _equal
	blt _less

	sub r1, r5, #1

	b _b_srch_loop

_less:
	add r0, r5, #1

	bal _b_srch_loop

_equal:
	mov r3, r5
	b _b_srch_exit

_not_found:
	mov r3, #-1

_b_srch_exit:
	bx lr
