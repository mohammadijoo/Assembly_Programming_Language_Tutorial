; file: math64.asm (NASM, x86-64)

global add64

section .text
; uint64_t add64(uint64_t a, uint64_t b)
; SysV AMD64 calling: a in rdi, b in rsi, return in rax
add64:
    mov rax, rdi
    add rax, rsi
    ret
