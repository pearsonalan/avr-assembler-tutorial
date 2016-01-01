;--------------------------------
; dice: an electronic dice roller
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


; ===========================
; delay macro
;
; input:
;   @0 - immediate count of how many milliseconds to delay
; regs altered:
;   r20 (milliseconds)
;
; wait until the given number of milliseconds have elapsed
; 
.macro delay
	clr overflows
	ldi milliseconds, @0
sec_count:
	cpse overflows, milliseconds
	rjmp sec_count
.endmacro


;=================
; Interrupt vectors

.org 0x0000
	rjmp Reset		; Jump to reset handler on reset

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
	
	;; fall through right into main

;=================
; main routine

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


; ====================
; wait_button routine
;
; wait until the button attached to PB0 is pressed
;

wait_button:
	sbic PINB, 0		; skip if PB0 is GND
	rjmp wait_button
	ret


; ====================
; random routine
;
; input: 
;   seed
; generate a random numbers in die1 and die2
;

random: 
	; attempt to generate random numbers
	out TCNT0, die1 
	add die1, seed
	swap seed
	delay 25
	out TCNT0, die2 
	add die2,seed
	clc
  d1:
	cpi die1, 6		; compare die1 with 6
	brlo d2			; if die1 < 6 then roll
	subi die1,6		; else subtract 6
	rjmp d1			; go back and compare again
  d2:
	cpi die2,6		; compare die2 with 6
	brlo roll		; if die < 6 then roll
	subi die2,6		; else subtract 6
	rjmp d2			; go back and compare again
  roll:
	ret 


; ====================
; dice routine
;
; input:
;   die1 (r18) - integer value of die 1 in the range [0,5]
;   die2 (r19) - integer value of die 2 in the range [0,5]
;
; output:
;   die1 (r18) - bitmask for setting the output pins on die1 to show the value
;   die2 (r19) - bitmast for setting the output pins on die2 to show the value
;
; regs altered:
;   temp
;   zl
;   zh
;
; take the integer numbers in die1 and die2 and use them
; to look up the bitmasks needed to show the dice in the
; LED displays. On output, die1 and die2 will contian
; the LED BITMASK values.
;

dice:
	ldi zl, low(numbers<<1)		; load address of the lookup table into Z register
	ldi zh, high(numbers<<1)	; need to multiply by 2 because address in program 
					; space is the count of words from 0, whereas we need
					; count of bytes from 0

	clr temp			; use temp register as high byte of addition, so we need it to be zero

	add zl, die1			; add low bytes together
	adc zh, temp			; add carry from low byte addition with 0 in temp register
	lpm die1, z			; load die1 with bit mask from lookup table

	ldi zl, low(numbers<<1)		; load address of the lookup table into Z register
	ldi zh, high(numbers<<1)

	add zl, die2			; add low bytes together
	adc zh, temp			; add carry from low byte addition with 0 in temp register
	lpm die2, z			; load die2 with bit mask from lookup table

	ret


; ====================
; cycle routine
;   input: none
;   output: none
;   regs altered: temp
;

cycle:
	rol temp		; shift bits left with wrap around
	delay 100		; delay (up to 250 ms)
	sec			; set the SREG carry flag
	out PORTC, temp		; PortC starts as 0b11111110
	sbrc temp, 6		; skip if bit 6 is cleared
	rjmp cycle		; otherwise loop back up
	ret


; =======================================
; display routine
;
; display the values on the dice LEDs
; loop until the button is pressed.
;

display:
	cbi PORTB, 4		; turn off die1
	cbi PORTB, 5		; turn off die2

  disploop:
	; set PC0:6 and PB1 according the the LED mask for die1
	sbi PORTB, 1		; turn off center led
	sbrs die1, 7		; skip next instruction if center led off
	cbi PORTB, 1		; turn on center led if needed
	out PORTC, die1		; turn on the other 6 LEDs according to the bits in die 1

	sbi PORTB, 4		; turn on die1
	delay 2			; short delay
	cbi PORTB, 4		; turn off die1

	; set PC0:6 and PB1 according the the LED mask for die2
	sbi PORTB, 1		; turn off center led
	sbrs die2, 7		; skip if center led off
	cbi PORTB, 1		; turn on center led if needed
	out PORTC,die2		; turn on the others

	sbi PORTB, 5		; turn on die2
	delay 2			; short delay
	cbi PORTB, 5		; turn off die2

	sbic PINB,0		; exit to main if button press
	rjmp disploop		; loop to the top
	ret 


; ======================================
; overflow_handler routine
; 
; called by interrupt on timer overflow
;

overflow_handler: 
	inc overflows		; increment 1000 times/sec
	add seed,overflows
	reti


; ==============================================
; numbers: lookup table for dice LED bitmasks
;
numbers:
	.db 0b01111111, 0b11011110, 0b01011110, 0b11010010 
	.db 0b01010010, 0b11000000

