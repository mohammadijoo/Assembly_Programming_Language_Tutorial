; Demonstrates: reserving patch space using times + NOP.
; (In real systems, patching requires discipline; here it's purely illustrative.)

BITS 64
global _start

SYS_exit equ 60

section .text
_start:
    ; Placeholder region for future instrumentation
    times 8 nop

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
