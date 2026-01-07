; x86-64 NASM: capture carry-out using SETC after ADD.
; Exit 1 if addition overflowed in unsigned sense (CF==1), else 0.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     al, 250
    add     al, 10          ; 250 + 10 = 260 -> wraps to 4, sets CF=1

    setc    bl              ; BL = carry flag
    movzx   edi, bl
    mov     eax, SYS_exit
    syscall
