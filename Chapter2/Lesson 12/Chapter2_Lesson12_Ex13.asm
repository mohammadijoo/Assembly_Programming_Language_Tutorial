; Size specifiers matter because they choose opcode variants.
; Here we store an 8-bit vs 32-bit value to the same memory location.

BITS 64
global _start
SYS_exit equ 60

section .data
x: dq 0

section .text
_start:
    mov     byte  [rel x], 0x7F
    mov     dword [rel x], 0x11223344

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
