BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ax, cs
    mov ds, ax

    mov si, msg_start
    call print_string

.hang:
    hlt
    jmp .hang

print_string:
.next_char:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .next_char
.done:
    ret

msg_start db "BOOT OK - AikyaOS Bootloader",0

times 510-($-$$) db 0
dw 0xAA55
