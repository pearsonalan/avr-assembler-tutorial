;************************************
; written by: 1o_o7 
; date: <2014|10|29>
; version: 1.0
; file saved as: blink.asm
; for AVR: atmega328p
; clock frequency: 16MHz (optional)
;************************************

; Program funcion:---------------------
; counts off seconds by blinking an LED
;
; PD4 ---> LED ---> R(330 ohm) ---> GND
;
;--------------------------------------

.nolist
.include "./m328Pdef.inc"
.list

;==============
; Declarations:

.def temp = r16
.def overflows = r17

;
; Set up the Interrupt Vector at 0x0000
;
; We only use 2 interrupts in this program, the RESET
; interrupt and the TIMER0 OVERFLOW interrupt.
;

.org 0x0000
	jmp Reset		; PC = 0x0000	RESET
	reti       		; PC = 0x0002
	nop
	reti       		; PC = 0x0004
	nop
	reti       		; PC = 0x0006
	nop
	reti       		; PC = 0x0008
	nop
	reti       		; PC = 0x000A
	nop
	reti       		; PC = 0x000C
	nop
	reti       		; PC = 0x000E
	nop
	reti       		; PC = 0x0010
	nop
	reti       		; PC = 0x0012
	nop
	reti       		; PC = 0x0014
	nop
	reti       		; PC = 0x0016
	nop
	reti       		; PC = 0x0018
	nop
	reti       		; PC = 0x001A
	nop
	reti       		; PC = 0x001C
	nop
	reti       		; PC = 0x001E
	nop

.org 0x0020
	jmp overflow_handler	; PC = 0x0020   TIMER0 OVF
	reti			; PC = 0x0022
	nop
	reti			; PC = 0x0024
	nop
	reti			; PC = 0x0026
	nop
	reti			; PC = 0x0028
	nop
	reti			; PC = 0x002A
	nop
	reti			; PC = 0x002C
	nop
	reti			; PC = 0x002E
	nop
	reti			; PC = 0x0030
	nop
	reti       		; PC = 0x0032
	nop


;============

.org 0x0034

Reset: 
	ldi	temp, 5
	out	TCCR0B, temp		; set the Clock Selector Bits CS00, CS01, CS02 to 101
					; this puts Timer Counter0, TCNT0 in to FCPU/1024 mode
					; so it ticks at the CPU freq/1024
	ldi	temp, 0b00000001
	sts	TIMSK0, temp		; set the Timer Overflow Interrupt Enable (TOIE0) bit 
					; of the Timer Interrupt Mask Register (TIMSK0)

	sei				; enable global interrupts -- equivalent to "sbi SREG, I"

	clr	temp
	out	TCNT0, temp		; initialize the Timer/Counter to 0

	sbi	DDRD, 4			; set PD4 to output

;======================
; Main body of program:

blink:
	sbi	PORTD, 4		; turn on LED on PD4
	rcall	delay			; delay will be 1/2 second
	cbi	PORTD, 4		; turn off LED on PD4
	rcall	delay			; delay will be 1/2 second
	rjmp	blink			; loop back to the start
  
delay:
	clr	overflows		; set overflows to 0 
sec_count:
	cpi	overflows, 30		; compare number of overflows and 30
	brne	sec_count		; branch to back to sec_count if not equal 
	ret				; if 30 overflows have occured return to blink

overflow_handler: 
	inc	overflows		; add 1 to the overflows variable
	cpi	overflows, 61		; compare with 61
	brne	ofh_ret			; Program Counter + 2 (skip next line) if not equal
	clr	overflows		; if 61 overflows occured reset the counter to zero
ofh_ret:
	reti				; return from interrupt

