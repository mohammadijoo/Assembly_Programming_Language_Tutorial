; src/exit0_nasm.asm
global _start
section .text
_start:
    mov rax, 60
    xor rdi, rdi
    syscall
