.PHONY: all upload

all: blink.hex

blink.hex: blink.asm
	avra -l blink.lst blink.asm

upload:
	avrdude -v -p m328p -c arduino -b 115200 -P /dev/ttyUSB0 -U flash:w:blink.hex
	
upload-isp:
	avrdude -C /usr/local/arduino-1.6.4/hardware/tools/avr/etc/avrdude.conf -v -p atmega328p -c usbtiny -U flash:w:blink.hex
	
clean:
	-rm blink.cof blink.eep.hex blink.hex blink.obj blink.lst
