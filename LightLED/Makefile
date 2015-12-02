.PHONY: all upload-hello upload-buttonled upload-buttonled2

all: hello.hex buttonled.hex buttonled2.hex

hello.hex: hello.asm
	avra hello.asm

buttonled.hex: buttonled.asm
	avra buttonled.asm

buttonled2.hex: buttonled2.asm
	avra buttonled2.asm

upload-hello:
	avrdude -v -p m328p -c arduino -b 115200 -P /dev/ttyACM0 -U flash:w:hello.hex
	
upload-buttonled:
	avrdude -v -p m328p -c arduino -b 115200 -P /dev/ttyACM0 -U flash:w:buttonled.hex

upload-buttonled2:
	avrdude -v -p m328p -c arduino -b 115200 -P /dev/ttyACM0 -U flash:w:buttonled2.hex

clean:
	-rm hello.cof hello.eep.hex hello.hex hello.obj
	-rm buttonled.cof buttonled.eep.hex buttonled.hex buttonled.obj
	-rm buttonled2.cof buttonled2.eep.hex buttonled2.hex buttonled2.obj
