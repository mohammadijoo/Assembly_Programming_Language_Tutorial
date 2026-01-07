; Demonstrates: local labels in NASM (labels beginning with a dot are local to previous non-local label)

BITS 64
global _start

SYS_exit equ 60

section .text
_start:
    mov     ecx, 5

.loop:
    ; simple countdown: ECX = ECX - 1 until zero
    dec     ecx
    jnz     .loop

.done:
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
