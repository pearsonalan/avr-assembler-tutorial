OSTYPE = $(shell uname -s)


ifeq ($(OSTYPE),Darwin)
  AVRCONF := /usr/local/avr/etc/avrdude.conf
  ifndef PORT
    PORT := /dev/cu.usbserial-AL00EZFL
  endif
else
  AVRCONF := /usr/local/arduino-1.6.4/hardware/tools/avr/etc/avrdude.conf
  ifndef PORT
    PORT := /dev/ttyUSB0
  endif
endif

ifndef BAUD
  BAUD := 115200
endif

AVRDUDE_FLAGS = -v -p atmega328p -c arduino -b $(BAUD) -P $(PORT) -C $(AVRCONF)

.PHONY: all upload

all: obj obj/dice-brute.hex obj/dice-macros.hex obj/dice.hex

obj:
	mkdir obj

obj/dice-brute.hex: obj dice-brute.asm
	avra -o obj/dice-brute.hex -e obj/dice-brute.eep.hex -l obj/dice-brute.lst -b obj/dice-brute.obj -d obj/dice-brute.cof dice-brute.asm

obj/dice-macros.hex: obj dice-macros.asm
	avra -o obj/dice-macros.hex -e obj/dice-macros.eep.hex -l obj/dice-macros.lst -b obj/dice-macros.obj -d obj/dice-macros.cof dice-macros.asm

obj/dice.hex: obj dice.asm
	avra -o obj/dice.hex -e obj/dice.eep.hex -l obj/dice.lst -b obj/dice.obj -d obj/dice.cof dice.asm

upload: upload-dice

upload-brute:
	avrdude $(AVRDUDE_FLAGS) -U flash:w:obj/dice-brute.hex

upload-macros:
	avrdude $(AVRDUDE_FLAGS) -U flash:w:obj/dice-macros.hex

upload-dice:
	avrdude $(AVRDUDE_FLAGS) -U flash:w:obj/dice.hex
	
upload-isp:
	avrdude -C $(AVRCONF) -v -p atmega328p -c usbtiny -U flash:w:obj/dice.hex
	
clean:
	-rm obj/dice-brute.hex obj/dice-brute.eep.hex obj/dice-brute.obj obj/dice-brute.cof obj/dice-brute.lst
	-rm obj/dice-macros.hex obj/dice-macros.eep.hex obj/dice-macros.obj obj/dice-macros.cof obj/dice-macros.lst
	-rm obj/dice.hex obj/dice.eep.hex obj/dice.obj obj/dice.cof obj/dice.lst
