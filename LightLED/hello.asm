;hello.asm
;  turns on an LED which is connected to PB4 (digital out 12)

.include "./m328Pdef.inc"

	ldi r16,0b00010000
	out DDRB,r16
	out PortB,r16

Start:
	rjmp Start
