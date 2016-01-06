;************************************
; written by: 1o_o7
; date: <2014|11|03>
; version: 1.0
; file saved as: analyzer.asm
; for AVR: atmega328p
; clock frequency: 16MHz
;************************************

; Program funcion:----------------------
; analyzes the bits stored in a register
;---------------------------------------

.nolist
.include "./m328Pdef.asm"
.list

.def  temp = r16

.org 0x0000
	rjmp  Init

Init:  
	ser temp
	out DDRB, temp
	out DDRC, temp
	clr temp
	out PortB, temp
	out PortC, temp

main:

	ldi ZH, high(2*numbers); ZH is the high byte of the address of numbers
	ldi ZL, low(2*numbers); ZL is the low byte of the address of numbers
	lpm r20, Z
	rcall analyze

foo:
	rjmp foo

analyze:
	clr temp
	out portb, temp
	out portc, temp
	sbrc r20, 7
	sbi portb, 1
	sbrc r20, 6
	sbi portb, 2
	sbrc r20, 5
	sbi portb, 3
	sbrc r20, 4
	sbi portb, 4
	sbrc r20, 3
	sbi portc, 1
	sbrc r20, 2
	sbi portc, 2
	sbrc r20, 1
	sbi portc, 3
	sbrc r20, 0
	sbi portc, 4
	ret

numbers:
	.db 0b01111111, 0b11011110, 0b01011110, 0b11010010 
	.db 0b01010010, 0b11000000

