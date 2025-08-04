CROSS ?= i686-elf-
CC = $(CROSS)gcc
LD = $(CROSS)ld
OBJCOPY = $(CROSS)objcopy
AS = nasm

CFLAGS = -ffreestanding -fno-pic -fno-stack-protector -m32 -nostdlib -Wall -Wextra
LDFLAGS = -T linker.ld -nostdlib -m elf_i386

all: aikyaos.iso

boot.bin: ../boot/boot.asm
	$(AS) -f bin $< -o $@

kernel.o: ../kernel/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

entry.o: ../kernel/entry.asm
	$(AS) -f elf32 $< -o $@

kernel.bin: kernel.o entry.o
	$(LD) $(LDFLAGS) entry.o kernel.o -o kernel.elf
	$(OBJCOPY) -O binary kernel.elf $@

os-image.bin: boot.bin kernel.bin
	cat $^ > $@

isodir:
	mkdir -p isodir
	cp os-image.bin isodir/boot.bin

aikyaos.iso: os-image.bin isodir
	xorriso -as mkisofs -R -b boot.bin -no-emul-boot -o $@ isodir

clean:
	rm -f *.o *.bin *.elf aikyaos.iso
	rm -rf isodir

run: all
	qemu-system-i386 -cdrom aikyaos.iso

.PHONY: all clean run
