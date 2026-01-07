; x86-64 NASM: signed less-than via flags (SF/OF) and SETL.
; Exit 1 if a < b (signed), else 0.

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    mov     eax, -5         ; a (signed)
    mov     ebx, 3          ; b

    cmp     eax, ebx
    setl    al              ; less (signed): (SF != OF)
    movzx   edi, al
    mov     eax, SYS_exit
    syscall
