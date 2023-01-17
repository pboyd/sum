; mul10 <addr>
;
; mul10 multiplies the 16-bit number at addr by 10, wrapping around if it
; overflows. The result is overwrites addr.
;
; This macro works on the premise that 2x + 8x = 10x
;
; Preserves A, X and Y
mul10	mac
	; Save old register state
	pha
	phx
	phy

	ldx ]1		; Copy lsb to X
	ldy ]1+1	; Copy msb to Y

	; Multiply by 2, and store the result
	txa		; Copy lsb to A
	asl A		; Multiply lsb by 2
	sta ]1		; Store lsb
	tya		; Copy msb to A
	rol A		; Multiply msb by 2
	sta ]1+1	; Store msb

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

	; Add the result
	txa		; Copy lsb to A
	clc		; Clear carry before add
	adc ]1		; Add 2x + 8x in lsb
	sta ]1		; Store lsb
	tya		; Copy msb to A
	adc ]1+1	; Add 2x + 8x in msb
	sta ]1+1	; Store msb

	; Restore old register state
	ply
	plx
	pla
	<<<
