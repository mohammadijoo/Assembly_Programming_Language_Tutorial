; Example use (NASM)
%include "print_macros.inc"

section .rodata
hi: db "Hi\n"
section .text
global _start
_start:
    lea rsi, [rel hi]
    WRITE_LIT rsi, 3
    mov eax, SYS_exit
    xor edi, edi
    syscall
