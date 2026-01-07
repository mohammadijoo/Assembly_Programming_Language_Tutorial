; file: use_include.asm (NASM)
%include "linux_sys.inc"

global _start

section .rodata
msg: db "Include files make large assembly projects sane.", 10
msg_len: equ $ - msg

section .text
_start:
    mov rax, SYS_write
    mov rdi, STDOUT_FD
    lea rsi, [rel msg]
    mov rdx, msg_len
    syscall

    sys_exit 0
