; lshiftStack16
;
; Pops two bytes from the stack shifts them to left one time and then pushes
; the result back. The least significant byte should be the first value popped.
;
; Clobbers X and Y, but preserves A.
lshiftStack16	mac
		plx		; get lsb
		ply		; get msb
		pha		; save accumulator

		txa		; copy lsb from X to A
		asl A		; left shift lsb
		tax		; copy lsb back to X
		bcs withCarry	; branch for carry

		tya		; copy msb from Y to A
		asl A		; left shift msb
		tay		; copy msb back to Y
		jmp cleanup	; done

withCarry
		tya		; copy msb from Y to A
		asl A		; left shift msb
		tay		; copy msb back to Y
		iny		; increase Y by 1 for the carry

cleanup
		pla		; restore original accumulator
		phy		; push msb back on the stack
		phx		; push lsb back on the stack
		<<<

; addStack16 addr
;
; addStack16 pops two bytes from the stack and adds them to the value at addr.
; The least significant byte should be the first value popped. The values are
; placed back on the stack.
;
; Clobbers X and Y, but preserves A.
addStack16	mac
		plx		; get lsb
		ply		; get msb
		pha		; save accumulator

		txa		; copy lsb from X to A
		clc		; clear carry before add
		adc ]1		; add lsb
		sta ]1		; store lsb
		tya		; copy msb from Y to A
		adc ]1+1	; add msb and carry flag
		sta ]1+1	; store msb

		pla		; restore original accumulator
		phy		; push msb back on the stack
		phx		; push lsb back on the stack
		<<<

; mul168 addr
;
; Multiplies a 16-bit number stored at the address by the accumulator and
; stores the result back at the same address.
;
; Clobbers A, X and Y.
mul168	mac
	ldx ]1+1	; load msb
	phx		; push msb to the stack
	ldx ]1		; load lsb
	phx		; push lsb to the stack

	; clear our product
	ldx #0
	stx ]1
	stx ]1+1

loop
	lsr A		; remove the least significant bit
	bcc dontAdd	; if the bit was 0 don't add

	addStack16 ]1	; the bit was 1, so increase the product

dontAdd
	cmp #0		; if A is 0...
	beq end		; we're done

	lshiftStack16	; shift for the next pass ("add a placeholder")
	jmp loop	; do it again

end
	; remove our temp values from the stack
	pla
	pla
	<<<

#return	ds 2		; mul stashes it's return address here
#
#mul
#	plx		; pop first byte of the return address
#	stx return	; store first byte
#	plx		; pop second byte
#	stx return+1	; store second byte
#
#	plx		; pop lsb
#	stx scratch+2	; store lsb
#	plx		; pop msb
#	stx scratch+3	; store lsb
#
#	ldx return+1	; get second byte of the return address
#	phx		; put it back on the stack
#	ldx return	; get first byte
#	phx		; put it back on the stack
#
#	rts
