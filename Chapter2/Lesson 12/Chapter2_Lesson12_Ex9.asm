; Control-flow distance changes encoding (short vs near jumps).
; The 'short' keyword forces an 8-bit displacement if possible.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    jmp     short .target
    ; filler bytes to show that distance matters (still within short range here)
    times 50 nop

.target:
    mov     eax, SYS_exit
    xor     edi, edi
    syscall
