; x86-64 Linux: write(1, msg, len) via syscall
; RAX = syscall number
; RDI = fd
; RSI = buf
; RDX = count

section .data
msg db "Hello from 64-bit", 10
len equ $ - msg

section .text
global _start
_start:
    mov rax, 1          ; SYS_write (64-bit)
    mov rdi, 1          ; fd=stdout
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60         ; SYS_exit (64-bit)
    xor rdi, rdi
    syscall
