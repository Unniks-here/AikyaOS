CROSS ?= i686-elf-
CC = $(CROSS)gcc
LD = $(CROSS)ld
OBJCOPY = $(CROSS)objcopy
AS = nasm

CFLAGS = -ffreestanding -fno-pic -fno-stack-protector -m32 -nostdlib -Wall -Wextra
LDFLAGS = -T linker.ld -nostdlib -m elf_i386

# Calculate kernel size in sectors (rounded up)
KERNEL_SECTORS = $(shell expr $$(stat -f%z kernel.bin 2>/dev/null || echo 512) / 512 + 1)

all: aikyaos.img

# ----------------------------
# Bootloader
# ----------------------------
boot.bin: ../boot/boot.asm kernel.bin
	$(AS) -f bin -DKERNEL_SECTORS=$(KERNEL_SECTORS) $< -o $@

# ----------------------------
# Kernel Objects
# ----------------------------
kernel.o: ../kernel/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

entry.o: ../kernel/entry.asm
	$(AS) -f elf32 $< -o $@

kernel.bin: kernel.o entry.o
	$(LD) $(LDFLAGS) entry.o kernel.o -o kernel.elf
	$(OBJCOPY) -O binary kernel.elf $@

# ----------------------------
# Raw Bootable Image (.img)
# ----------------------------
aikyaos.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > aikyaos.img

# ----------------------------
# ISO Build (El Torito)
# ----------------------------
iso: aikyaos.img
	mkdir -p isodir
	cp aikyaos.img isodir/aikyaos.img
	xorriso -as mkisofs -R \
	    -b aikyaos.img \
	    -no-emul-boot -boot-load-size 4 -boot-info-table \
	    -o aikyaos.iso isodir

# ----------------------------
# Run in QEMU
# ----------------------------
run-img: aikyaos.img
	qemu-system-i386 -drive format=raw,file=aikyaos.img

run-iso: iso
	qemu-system-i386 -cdrom aikyaos.iso

# ----------------------------
# Clean
# ----------------------------
clean:
	rm -f *.o *.bin *.elf aikyaos.iso aikyaos.img
	rm -rf isodir

.PHONY: all clean run-img run-iso iso
