; Increase the distance so a short jump is no longer possible.
; Many assemblers will automatically choose a near jump.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    jmp     .far_target
    times 300 nop   ; likely pushes target beyond 8-bit displacement

.far_target:
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
