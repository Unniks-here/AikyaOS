; entry.asm - 32-bit kernel entry
BITS 32
SECTION .text.start
GLOBAL _start
EXTERN kmain

_start:
    cli
    mov esp, 0x9FB00
    call kmain
.hang:
    hlt
    jmp .hang
