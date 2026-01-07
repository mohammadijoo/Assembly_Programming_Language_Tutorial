; file: reloc_store.asm
default rel
global _start

section .data
p_msg: dq 0

section .rodata
msg: db "Relocation demo", 0

section .text
_start:
    ; Store address of msg into p_msg (forces relocation in .data)
    lea rax, [msg]
    mov [p_msg], rax

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
