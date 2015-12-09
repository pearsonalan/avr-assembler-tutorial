; Program function:---------------
;
; A dice roller
;
; LEDs on PC0 through 5 
; and the center one on PB1
; Button on PB0
; anodes on PB4 and PB5
;
;--------------------------------

.nolist
.include "./m328Pdef.asm"
.list

;=================
; Declarations:

.def temp	  = r16
.def overflows	  = r17
.def die1	  = r18
.def die2	  = r19
.def milliseconds = r20
.def seed	  = r21

;=================
; Interrupt vectors

.org 0x0000
	rjmp Reset
.org 0x0020			; Timer0 overflow handler
	rjmp overflow_handler

;=================
; Start of Program

.org 0x0034

Reset: 
	ldi temp, 0b00000011
	out TCCR0B, temp	; TCNT0 in FCPU/64 mode, so 250000 cnts/sec
	ldi temp, 249
	out OCR0A, temp		; top of counter at 250 counts/overflow
				;   so overflow occurs every 1/1000 sec
				;   this means an overflow every 1ms
	ldi temp, 0b00000010
	out TCCR0A, temp	; reset TCNT0 at value in OCR0A
	sts TIMSK0, temp	; Enable Timer Overflow Interrupts
	sei			; enable global interrupts

	ldi temp, 0b11111110
	out DDRB, temp		; PB0 input the rest output
	ldi temp, 0b11111111
	out DDRC, temp		; PortC all output

main: 
	ser temp
	out PORTB, temp		; all PortB at 5V
	out PORTC, temp		; all PortC at 5V
	rcall wait_button	; wait for button
	rcall random		; get rand nums die1, die2
	rcall dice		; set up dice leds
	ser temp		; set temp for cycle
	rcall cycle		; animate dice throw
	rcall display		; display the result
	rjmp main

wait_button:
	sbic PINB, 0		; skip if PB0 is GND
	rjmp wait_button
	ret

random: 
	; attempt to generate random numbers
	out TCNT0, die1 
	add die1, seed
	swap seed
	ldi milliseconds, 10
	rcall delay
	out TCNT0, die2 
	add die2, seed
	clc
d1:
	cpi die1, 6		; compare die1 with 6
	brlo d2			; if die1 < 6 then roll
	subi die1, 6		; else subtract 6
	rjmp d1			; go back and compare again
d2:
	cpi die2, 6		; compare die2 with 6
	brlo roll		; if die < 6 then roll
	subi die2, 6		; else subtract 6
	rjmp d2			; go back and compare again
roll:
	inc die1		; add 1 so between 1 and 6
	inc die2
	ret 

dice:
	cpi die1, 1		; compare die1 with 1
	brne PC+2		; if not equal don't set die1
	ldi die1, 0b01111111	; 7th bit set off denotes a 1
	cpi die2, 1		; compare die2 with 1
	brne PC+2		; if not equal don't set die2
	ldi die2, 0b01111111

	cpi die1, 2
	brne PC+2
	ldi die1, 0b11110011
	cpi die2, 2
	brne PC+2
	ldi die2, 0b11110011

	cpi die1, 3
	brne PC+2
	ldi die1, 0b01011110
	cpi die2, 3
	brne PC+2
	ldi die2, 0b01011110

	cpi die1, 4
	brne PC+2
	ldi die1, 0b11010010
	cpi die2, 4
	brne PC+2
	ldi die2, 0b11010010

	cpi die1, 5
	brne PC+2
	ldi die1, 0b01010010	; a 4 bit with 7th bit off so 5
	cpi die2, 5
	brne PC+2
	ldi die2, 0b01010010

	cpi die1, 6
	brne PC+2
	ldi die1, 0b11000000
	cpi die2, 6
	brne PC+2
	ldi die2, 0b11000000
	ret

cycle:
	rol temp		; shift bits left with wrap around
	ldi milliseconds, 100	; delay (up to 250 ms)
	rcall delay
	sec			; set the SREG carry flag
	out PORTC, temp		; PortC starts as 0b11111110
	sbrc temp, 6		; skip if bit 6 is cleared
	rjmp cycle		; otherwise loop back up
	ret


display:
	sbi PORTB, 0		; set button to off
	sbi PORTB, 1		; turn off center led
	ldi milliseconds, 2	; set a short delay
	sbi PORTB, 4		; turn on die1
	cbi PORTB, 5		; turn off die2
	sbrs die1, 7		; skip if center led off
	cbi PORTB, 1		; turn on center led if needed
	out PORTC, die1		; turn on the others
	rcall delay		; short delay
	sbi PORTB, 1		; turn off center led
	cbi PORTB, 4		; turn off die1
	sbi PORTB, 5		; turn on die2
	sbrs die2, 7		; skip if center led off
	cbi PORTB, 1		; turn on center led if needed
	out PORTC, die2		; turn on the others
	rcall delay		; short delay
	sbic PINB, 0		; exit to main if button press
	rjmp display		; loop to the top
	ret 

overflow_handler: 
	inc overflows		; increment 1000 times/sec
	add seed, overflows
	reti

delay:
	clr overflows
sec_count:
	cpse overflows, milliseconds
	rjmp sec_count
	ret
