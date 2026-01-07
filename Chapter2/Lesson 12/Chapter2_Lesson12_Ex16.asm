; Solution-oriented: align a hot label and observe padding bytes.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    jmp     .hot

    ; cold path padding
    times 23 nop

align 16
.hot:
    ; hot path: minimal work
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
