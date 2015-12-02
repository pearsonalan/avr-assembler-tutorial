; buttonled2.asm
;  
; written by: alan pearson
;
; implements the same function as buttonled.asm but using
; the SBI and CBI instructions instead of LDI and OUT
;


; Program function:------------------------------
; Turns on an led connected to PB0 (digital 0)
; when you push a button connected to PD0
;-----------------------------------------------
;
;  PB0 (normally 0V) -----> LED --> 220 Ohm ---> 5V
;
;  PD0 (normally 5V) -----> Button ---> GND
;


.nolist
.include "./m328Pdef.inc"
.list

	rjmp	Init			; jump to start of program

Init:
	sbi		DDRB, 0			; set bit 0 of DDRB to 1. This sets the data direction
							; of PB0 (digital out 8) to output

	cbi		DDRD, 0         ; clear bit 0 of DDRD, which sets PD0 (ditigal pin 0) to
							; input

	clr		r16				; set all bits in r16 to 0
	out		PORTB, r16		; send 0's to PORTB, setting BP0 to 0V

	ldi		r16, $01		; move a 1 to port D, setting PD0 to 5V
	out		PORTD, r16

	ldi		r17, $01		; create a mask to mask off pin 0

main:
	in		r16, PIND		; read the state of the D pins into r16
	and		r16, r17		; and with the mask in r17 to isolate pin PD0
	cp		r16, r17		; compare with the mask $01 to test if it is set

	breq	ledon			; if equal to 1 (PD0 is high), branch
	cbi		PORTB, 0		; PD0 is LOW => clear bit 0 of PORTB (PB0 where LED is)
	rjmp    main			; loop to start
	
ledon:						; branch here if PD0 is high
	sbi		PORTB, 0		; PD0 HIGH => set bit 0 of PORTB (PB0)
	rjmp	main			; loop to start

