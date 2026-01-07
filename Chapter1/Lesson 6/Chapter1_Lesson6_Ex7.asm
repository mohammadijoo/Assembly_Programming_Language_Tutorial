; src/exit0.asm
; x86-64 Linux, NASM syntax, no libc.
; Exits with status code 0.

global _start

section .text
_start:
    mov     rax, 60         ; syscall: exit
    xor     rdi, rdi        ; status = 0
    syscall
