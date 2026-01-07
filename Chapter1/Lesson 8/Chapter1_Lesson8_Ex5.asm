; file: main64.asm (NASM, x86-64)

extern add64
global _start

section .text
_start:
    mov rdi, 40
    mov rsi, 2
    call add64          ; relocation against symbol add64
    ; rax = 42

    ; Linux syscall exit(status=rax)
    mov rdi, rax
    mov rax, 60         ; SYS_exit
    syscall
