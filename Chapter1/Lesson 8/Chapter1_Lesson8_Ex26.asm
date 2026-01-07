; file: sum_fixed.asm
global sum_fixed
section .text
sum_fixed:
    push rbx
    mov rbx, rdi
    add rbx, rsi
    mov rax, rbx
    pop rbx
    ret
