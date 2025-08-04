; boot.asm - Phase 2 bootloader for AikyaOS
BITS 16
ORG 0x7C00

%ifndef KERNEL_SECTORS
%error "KERNEL_SECTORS must be defined by the build system"
%endif

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl       ; save boot drive

    ; -------------------------------
    ; Read kernel from disk to 0x1000
    ; -------------------------------
    mov bx, 0x1000             ; destination address
    mov ah, 0x02               ; BIOS read function
    mov al, KERNEL_SECTORS
    mov ch, 0                  ; cylinder
    mov cl, 2                  ; sector (kernel starts at sector 2)
    mov dh, 0                  ; head
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    ; -------------------------------
    ; Setup GDT and enter protected mode
    ; -------------------------------

gdt_start:
gdt_null:   dq 0
gdt_code:   dq 0x00CF9A000000FFFF
gdt_data:   dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pmode_entry

[BITS 32]
pmode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    jmp 0x08:0x1000            ; jump to loaded kernel

disk_error:
    hlt
    jmp disk_error

boot_drive: db 0

times 510-($-$$) db 0
dw 0xAA55
