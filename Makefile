CROSS ?= i686-elf-
CC = $(CROSS)gcc
LD = $(CROSS)ld
OBJCOPY = $(CROSS)objcopy
AS = nasm
.RECIPEPREFIX := >

CFLAGS = -ffreestanding -fno-pic -fno-stack-protector -m32 -nostdlib -Wall -Wextra
LDFLAGS = -T linker.ld -nostdlib -m elf_i386

BOOT_BIN = boot.bin
KERNEL_BIN = kernel.bin
IMG = aikyaos.img

all: $(IMG)

kernel_entry.o: kernel/entry.asm
>$(AS) -f elf32 $< -o $@

kernel.o: kernel/kernel.c
>$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_BIN): kernel_entry.o kernel.o
>$(LD) $(LDFLAGS) -o kernel.elf kernel_entry.o kernel.o
>$(OBJCOPY) -O binary kernel.elf $@

$(BOOT_BIN): boot/boot.asm $(KERNEL_BIN)
>set -e; \
>KS=$$(stat -c%s $(KERNEL_BIN)); \
>SECT=$$(( (KS + 511) / 512 )); \
>$(AS) -f bin -DKERNEL_SECTORS=$$SECT $< -o $@

$(IMG): $(BOOT_BIN) $(KERNEL_BIN)
>cat $(BOOT_BIN) $(KERNEL_BIN) > $@

run-img: $(IMG)
>qemu-system-i386 -drive format=raw,file=$(IMG)

clean:
>rm -f $(BOOT_BIN) kernel_entry.o kernel.o kernel.elf $(KERNEL_BIN) $(IMG)

.PHONY: all clean run-img
