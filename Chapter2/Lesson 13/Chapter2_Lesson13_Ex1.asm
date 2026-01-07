; x86-64 NASM: equality test via flags (ZF) and SETE.
; We exit with 1 if a == b else 0.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     eax, 123
    mov     ebx, 123

    cmp     eax, ebx        ; sets ZF=1 iff eax-ebx == 0
    sete    al              ; AL = (ZF==1) ? 1 : 0

    movzx   edi, al         ; exit status
    mov     eax, SYS_exit
    syscall
