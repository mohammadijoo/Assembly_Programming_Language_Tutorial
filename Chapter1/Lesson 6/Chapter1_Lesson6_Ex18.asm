; src/hello_inc.asm
global _start
%include "include/linux_syscalls_amd64.inc"

section .data
msg: db "Using include files for syscall constants", 10
len: equ $ - msg

section .text
_start:
    mov rax, SYS_write
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, len
    syscall

    mov rax, SYS_exit
    xor rdi, rdi
    syscall
