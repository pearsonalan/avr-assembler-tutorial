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

all: build

build: obj obj/analyze.hex

obj:
	mkdir obj

obj/analyze.hex: obj analyze.asm
	avra -o obj/analyze.hex -e obj/analyze.eep.hex -l obj/analyze.lst -b obj/analyze.obj -d obj/analyze.cof -m obj/analyze.map analyze.asm

upload:
	avrdude $(AVRDUDE_FLAGS) -U flash:w:obj/analyze.hex
	
upload-isp:
	avrdude -C $(AVRCONF) -v -p atmega328p -c usbtiny -U flash:w:obj/analyze.hex
	
clean:
	-rm obj/analyze.hex obj/analyze.eep.hex obj/analyze.obj obj/analyze.cof obj/analyze.lst obj/analyze.map
