; entry.asm - 32-bit kernel entry for AikyaOS
BITS 32
GLOBAL _start
EXTERN kmain

SECTION .text
_start:
    mov esp, stack_top      ; set up stack
    call kmain              ; jump into C kernel
.hang:
    hlt
    jmp .hang

SECTION .bss
align 16
stack_bottom:
    resb 4096               ; 4 KiB stack
stack_top:

