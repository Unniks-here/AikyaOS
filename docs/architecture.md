# AikyaOS Phase 2 Architecture

AikyaOS begins as a minimal hybrid microkernel. Only the core services – task
scheduling, basic interrupt dispatch and a text console – live inside the
kernel. Device drivers and system servers will run in user mode in later
phases and communicate through an IPC mechanism.

## Boot Flow

1. The BIOS loads the 512 byte boot sector (`boot/boot.asm`) to 0x7C00.
2. The boot sector loads the kernel image located in the following sectors
   into memory at 0x1000 and switches the CPU to 32‑bit protected mode.
3. Control jumps to the kernel entry point where the C runtime starts.
4. The 32-bit entry stub sets up a stack and calls into the C kernel.
5. The kernel initializes the VGA text console and prints a boot message.

## Memory Map

```
0x00000000 - 0x000003FF : Real mode IVT
0x00007C00 - 0x00007DFF : Boot sector
0x00001000 - 0x00008FFF : Loaded kernel image
0x00090000 - 0x00090FFF : Temporary stack
0x000B8000 - 0x000B8FFF : VGA text buffer
```

The kernel currently runs in identity mapped low memory. A higher half
layout and paging will be introduced in later phases.

## Future Work

- Scheduler, IPC and user mode drivers.
- Paging and virtual memory separation.
- Filesystem and user programs.
