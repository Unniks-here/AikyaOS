#include <stdint.h>

typedef uint32_t size_t;

static uint16_t *const VGA_BUFFER = (uint16_t *)0xB8000;
static const uint8_t WHITE_ON_BLACK = 0x0F;

void kmain(void) {
    const char *msg = "AikyaOS Kernel Phase 2 Running in Protected Mode";
    for (size_t i = 0; msg[i]; ++i) {
        VGA_BUFFER[i] = ((uint16_t)msg[i]) | ((uint16_t)WHITE_ON_BLACK << 8);
    }
    for (;;) {
        __asm__ volatile("hlt");
    }
}
