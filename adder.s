	org $800

prntax	equ $f941
crout1	equ $fd8b

	jmp start
	use multiply.s
page	equ $40

; Main program
start
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
	mul10 curr	; multiply by 10

	clc		; clear carry before add
	adc curr	; add digit to lsb
	sta curr	; store digit in lsb
	lda #0		; clear A to add carry
	adc curr+1	; add carry to msb
	sta curr+1	; store msb
	jmp next

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
	bne jumpLoop	; if we did not overflow

nextPage
	dex		; end of a page, decrecrment X
	beq end		; if X is zero then we are done

	inc page+1	; increment msb of the page counter

jumpLoop
	jmp loop

end
	lda curr	; get lsb of the current number
	clc		; clear carry before add
	adc total	; add lsb of current to the total
	sta total	; store lsb of the current total
	lda curr+1	; get msb of the current number
	adc total+1	; add msb of current to the toal
	sta total+1	; store msb of the current total

	jsr crout1
	ldx total
	lda total+1
	jsr prntax

	;rts
	jmp $3d0

text	asc "123"
	db 0
total	db 0
	db 0
curr	db 0
	db 0
