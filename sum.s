	org $800

cout	equ $fded
crout1	equ $fd8b
page	equ $40

main
	ldy #0		; Y will count up through the each page
	ldx #4		; X will count down for four pages

	lda #0		; start at page $400
	sta page
	lda #$04
	sta page+1
loop
	lda (page),Y	; get digit at index Y
	and #$7f	; ignore high bit
	sec		; set carry before subtract
	sbc #$30	; subtract ASCII 0 to get a digit

	bmi nonDigit	; if the "digit" is less than 0
	cmp #10		; compare to decimal 10
	bcs nonDigit	; if A > 9

digit
	phx		; save X
	phy		; save Y

	ldx curr	; copy lsb to X for multiply
	ldy curr+1	; copy msb to Y for multiply
	jsr mul10	; multiply by 10
	stx curr	; store lsb of mul10 result
	sty curr+1	; store msb of mul10 result

	ply		; restore Y
	plx		; restore X

	clc		; clear carry before add
	adc curr	; add digit to lsb
	sta curr	; store digit in lsb
	lda #0		; clear A to add carry
	adc curr+1	; add carry to msb
	sta curr+1	; store msb
	bra next

nonDigit
	phx		; save X
	lda curr	; get lsb of the current number
	ldx curr+1	; get msb of the current number
	bne notZero	; if msb is not zero
	cmp #0		; if lsb is not zero
	bne notZero

	plx		; current is zero, pop x
	bra next	; go to the next number

notZero
	clc		; clear carry before add
	adc total	; add lsb of current to the total
	sta total	; store lsb of the current total
	txa		; copy msb from X to A
	adc total+1	; add msb of current to the total
	sta total+1	; store msb of the current total

	plx		; restore X

	lda #0		; clear current
	sta curr
	sta curr+1

next
	iny		; go to the next character
	bne loop	; if we did not overflow

nextPage
	dex		; end of a page, decrecrment X
	beq end		; if X is zero then we are done

	inc page+1	; increment msb of the page counter
	bra loop	; do it again

end
	lda curr	; get lsb of the current number
	clc		; clear carry before add
	adc total	; add lsb of current to the total
	sta total	; store lsb of the current total
	lda curr+1	; get msb of the current number
	adc total+1	; add msb of current to the toal
	sta total+1	; store msb of the current total

	jsr crout1	; print carriage return
	ldx total	; load lsb in X
	ldy total+1	; load msb in Y
	jsr prntDec	; print it

	jmp $3d0	; exit

; mul10 multiplies a 16-bit number by 10. If the result does not fit in 16 bits
; it will overflow. It works on the premise that 2x + 8x = 10x
;
; The least significant byte of the number comes from X, the most significant
; byte comes from Y. The output is returned in the same way.
;
; It preserves the A register.
mul10
	pha		; Save old A value

	; Multiply by 2, and store the result
	txa		; Copy lsb to A
	asl A		; Multiply lsb by 2
	sta temp	; Store lsb
	tya		; Copy msb to A
	rol A		; Multiply msb by 2
	sta temp+1	; Store msb

	; Multiply by 2, keep the result in X and Y
	txa		; Copy lsb to A
	asl A		; Multiply lsb by 2
	tax		; Put lsb back in X
	tya		; Copy msb to A
	rol A		; Multiply msb by 2
	tay		; Put msb back in Y

	; Repeat for 4 times
	txa		; Copy lsb to A
	asl A		; Multiply lsb by 2
	tax		; Put lsb back in X
	tya		; Copy msb to A
	rol A		; Multiply msb by 2
	tay		; Put msb back in Y

	; Repeat for 8 times
	txa		; Copy lsb to A
	asl A		; Multiply lsb by 2
	tax		; Put lsb back in X
	tya		; Copy msb to A
	rol A		; Multiply msb by 2
	tay		; Put msb back in Y

	; Find 2x + 8x
	txa		; Copy lsb to A
	clc		; Clear carry before add
	adc temp	; Add 2x + 8x in lsb
	tax		; Store lsb in X
	tya		; Copy msb to A
	adc temp+1	; Add 2x + 8x in msb
	tay		; Store msb in Y

	pla		; Restore A
	rts

; variables for div168
dividend dw 0
divisor	 db 0
rem	 db 0

; div168 divides a 16-bit number by an 8-bit number.
;
; The dividend is in X and Y with the least significant byte in X and the most
; significant byte in Y. The divisor is in A.
;
; The quotient is returned in X and Y with the remainder in A.
div168
	sta divisor	; store divisor

	stx dividend	; store lsb of the dividend
	sty dividend+1	; store msb of the dividend

	lda #0		; clear remainder
	sta rem

	ldx #$10	; 16 bits in our dividend

div168loop
	asl dividend	; shift lsb of the dividend
	rol dividend+1	; shift msb of the dividend
	rol rem		; shift the overflow into the remainder

	lda rem		; attempt to subtract divisor from rem
	sec		; set carry before subtraction
	sbc divisor	; subtract
	bcc div168next	; if rem < divisor, loop again

	sta rem		; store the result of the subtraction
	inc dividend	; add a 1 in the result

div168next
	dex
	bne div168loop

	ldx dividend	; put lsb of quotient in X
	ldy dividend+1	; put msb of quotient in Y
	lda rem		; put remainder in A

	rts

; prntDec prints a 16-bit number in decimal.
;
; The least significant byte of the number comes from X, the most significant
; byte comes from Y.
;
; Clobbers A, X and Y.
prntDec
	lda #0		; clear index var
	pha

prntDecLoop
	lda #10		; set divisor
	jsr div168	; divide XY by 10

	clc		; clear carry before add
	adc #$b0	; add remainder to ascii 0

	stx temp	; save X in the temp var
	plx		; pull the index from the stack
	sta buffer,X	; store the digit in the buffer
	inx		; increase the index
	phx		; push the index back to the stack
	ldx temp	; restore X from the temp var

	txa		; is the lsb > 0?
	bne prntDecLoop
	tya		; is the msb > 0?
	bne prntDecLoop

	plx		; pull the loop index
prntDecOutput
	dex		; decrement the index
	lda buffer,X	; get next character
	jsr cout	; print the next character

	txa		; check is X is 0
	bne prntDecOutput

	rts

; Variables
total	dw 0
curr	dw 0
temp	dw 0
buffer	ds 5
