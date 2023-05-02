.include "i_o.s"
.include "bin_search.s"

.global main

.text
main:
	bl d_in

	mov r0, #0

	ldr r1, [r8]
	sub r1, r1, #1

	ldr r2, [r8, #-4]

	bl b_srch

	bl d_out

	mov r7, #1
	swi 0
