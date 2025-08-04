; boot.asm - 16-bit boot sector for AikyaOS
BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl

    ; Load kernel (assumes <20 sectors)
    mov bx, 0x1000        ; load address
    mov ah, 0x02          ; BIOS read
    mov al, 20            ; number of sectors
    mov ch, 0
    mov cl, 2             ; start sector
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

; GDT for protected mode

gdt_start:
gdt_null:   dq 0
gdt_code:   dq 0x00CF9A000000FFFF
gdt_data:   dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

    ; Enter protected mode
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_mode

[BITS 32]
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    jmp 0x08:0x1000 ; jump to kernel

disk_error:
    hlt
    jmp disk_error

boot_drive: db 0

times 510-($-$$) db 0
dw 0xAA55
