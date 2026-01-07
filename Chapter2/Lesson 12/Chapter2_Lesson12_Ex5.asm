; Displacement encoding: disp0/disp8/disp32.
; Same logical address expression, different bytes.

BITS 64
global _start

SYS_exit equ 60

section .data
arr: dq 1,2,3,4

section .text
_start:
    lea     rbx, [rel arr]
    mov     rax, [rbx]          ; disp0
    mov     rax, [rbx+8]        ; disp8
    mov     rax, [rbx+0x1234]   ; disp32 (even if out-of-range logically)

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
