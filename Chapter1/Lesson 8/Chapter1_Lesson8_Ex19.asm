; file: mul_add.asm
global mul_add64
section .text
; uint64_t mul_add64(uint64_t a, uint64_t b, uint64_t c) = a*b + c
; SysV: a=rdi, b=rsi, c=rdx
mul_add64:
    mov rax, rdi
    imul rax, rsi
    add rax, rdx
    ret
