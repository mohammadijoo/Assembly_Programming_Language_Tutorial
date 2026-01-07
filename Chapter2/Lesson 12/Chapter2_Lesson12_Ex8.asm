; LEA is encoded like a memory-form instruction but does not dereference memory.
; Compare: LEA reg,[base+index*scale+disp] vs sequences of ADD/SHL.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     rbx, 100
    mov     rcx, 7

    ; rax = rbx + rcx*4 + 16
    lea     rax, [rbx + rcx*4 + 16]

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
