; NOP has multiple encodings; assemblers often choose canonical forms.
; xchg eax,eax is historically a 1-byte "nop-like" instruction (0x90).

BITS 64
global _start
SYS_exit equ 60

section .text
_start:
    nop                 ; 0x90 on x86
    xchg    eax, eax    ; also 0x90

    mov     eax, SYS_exit
    xor     edi, edi
    syscall
