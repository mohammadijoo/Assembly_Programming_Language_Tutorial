; hello_inc.asm
BITS 64
%include "linux_syscalls_x86_64.inc"

section .data
    msg db "Hello with include file!", 10
    msg_len equ $ - msg

section .text
global _start
_start:
    mov eax, SYS_write
    mov edi, STDOUT_FD
    lea rsi, [rel msg]
    mov edx, msg_len
    syscall

    mov eax, SYS_exit
    xor edi, edi
    syscall
