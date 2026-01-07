; Chapter 4 - Lesson 12 (Ex3)
; Signed division: IDIV expects sign-extended numerator in RDX:RAX.
; Use CQO (sign-extend RAX into RDX) for 64-bit signed division.

bits 64
default rel
global _start

section .text
_start:
    ; Compute (-7) / 3 => quotient = -2, remainder = -1 (x86 remainder has sign of dividend)
    mov     rax, -7
    cqo                         ; RDX:RAX = sign-extended RAX
    mov     rcx, 3
    idiv    rcx                 ; RAX=quot, RDX=rem

    ; Exit(0)
    mov     eax, 60
    xor     edi, edi
    syscall
