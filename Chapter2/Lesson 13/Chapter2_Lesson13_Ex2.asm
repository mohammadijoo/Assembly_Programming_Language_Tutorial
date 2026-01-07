; x86-64 NASM: unsigned less-than via flags (CF) and SETB.
; Exit 1 if a < b (unsigned), else 0.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     eax, 10         ; a
    mov     ebx, 20         ; b

    cmp     eax, ebx
    setb    al              ; below (unsigned): CF==1
    movzx   edi, al
    mov     eax, SYS_exit
    syscall
