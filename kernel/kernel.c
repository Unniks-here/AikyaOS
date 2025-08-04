#include <stdint.h>

typedef uint32_t size_t;

#define VGA_ADDR 0xB8000
#define WHITE_ON_BLACK 0x0F

static uint16_t *const vga_buffer = (uint16_t *)VGA_ADDR;

static void kprint(const char *s) {
    size_t i = 0;
    while (s[i]) {
        vga_buffer[i] = (uint16_t)s[i] | (WHITE_ON_BLACK << 8);
        i++;
    }
}

struct gdt_entry {
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t  base_mid;
    uint8_t  access;
    uint8_t  gran;
    uint8_t  base_high;
} __attribute__((packed));

struct gdt_ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

static struct gdt_entry gdt[3];
static struct gdt_ptr gp;

static void gdt_set_gate(int num, uint32_t base, uint32_t limit,
                         uint8_t access, uint8_t gran) {
    gdt[num].base_low = base & 0xFFFF;
    gdt[num].base_mid = (base >> 16) & 0xFF;
    gdt[num].base_high = (base >> 24) & 0xFF;

    gdt[num].limit_low = limit & 0xFFFF;
    gdt[num].gran = ((limit >> 16) & 0x0F) | (gran & 0xF0);
    gdt[num].access = access;
}

static inline void lgdt(struct gdt_ptr *g) {
    __asm__ volatile("lgdt (%0)" : : "r"(g));
}

static inline void lidt(void *i) {
    __asm__ volatile("lidt (%0)" : : "r"(i));
}

struct idt_entry {
    uint16_t base_low;
    uint16_t sel;
    uint8_t  always0;
    uint8_t  flags;
    uint16_t base_high;
} __attribute__((packed));

struct idt_ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

static struct idt_entry idt[256];
static struct idt_ptr idtp;

static void idt_install(void) {
    idtp.limit = sizeof(struct idt_entry) * 256 - 1;
    idtp.base = (uint32_t)&idt;

    for (int i = 0; i < 256; i++) {
        idt[i].base_low = 0;
        idt[i].sel = 0;
        idt[i].always0 = 0;
        idt[i].flags = 0;
        idt[i].base_high = 0;
    }

    lidt(&idtp);
}

static void gdt_install(void) {
    gp.limit = sizeof(gdt) - 1;
    gp.base = (uint32_t)&gdt;

    gdt_set_gate(0, 0, 0, 0, 0);
    gdt_set_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
    gdt_set_gate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);

    lgdt(&gp);

    __asm__ volatile(
        "mov $0x10, %%ax\n"
        "mov %%ax, %%ds\n"
        "mov %%ax, %%es\n"
        "mov %%ax, %%fs\n"
        "mov %%ax, %%gs\n"
        "mov %%ax, %%ss\n"
        "ljmp $0x08, $.flush\n"
        ".flush:\n"
        : : : "ax");
}

void kmain(void) {
    gdt_install();
    idt_install();
    kprint("AikyaOS Phase1");
    for (;;) {
        __asm__ volatile("hlt");
    }
}
