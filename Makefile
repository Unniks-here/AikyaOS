CROSS ?= i686-elf-

all:
	make -C build all CROSS=$(CROSS)

clean:
	make -C build clean CROSS=$(CROSS)

run:
	make -C build run CROSS=$(CROSS)