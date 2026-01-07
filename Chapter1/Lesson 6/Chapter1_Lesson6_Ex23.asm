; src/sections.asm
global _start

section .rodata
banner: db "ELF sections validated", 10
banner_len equ $ - banner

section .data
counter: dq 0

section .text
_start:
    ; write(1, banner, banner_len)
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel banner]
    mov rdx, banner_len
    syscall

    ; counter += 1
    mov rax, [rel counter]
    add rax, 1
    mov [rel counter], rax

    ; exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall
