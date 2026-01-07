; Demonstrates: section alignment attribute and the ALIGN directive.

BITS 64
global _start

SYS_exit equ 60

section .text align=16
_start:
    ; Force the next label to be 16-byte aligned (useful for performance-sensitive code layout)
    align 16
aligned_label:
    nop
    nop
    nop

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
