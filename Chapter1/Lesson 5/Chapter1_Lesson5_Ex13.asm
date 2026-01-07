; file: main.asm
%include "sys_linux64.inc"

global _start

section .data
msg: db "Includes make low-level code scalable.", 10
len: equ $ - msg

section .text
_start:
    mov     rax, SYS_write
    mov     rdi, FD_STDOUT
    lea     rsi, [rel msg]
    mov     rdx, len
    syscall

    mov     rax, SYS_exit
    xor     rdi, rdi
    syscall
