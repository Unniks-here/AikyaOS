ENTRY(_start)

SECTIONS
{
    . = 0x1000;
    .text : {
        *(.text.start)   /* Ensure entry.asm comes first */
        *(.text*)        /* Then rest of kernel code */
    }
    .rodata : { *(.rodata*) }
    .data : { *(.data*) }
    .bss : { *(.bss*) *(COMMON) }
}
