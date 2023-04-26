.include "i_o.s"

.global main

.text
main:
	bl d_in

	mov r7, #1
	swi 0
