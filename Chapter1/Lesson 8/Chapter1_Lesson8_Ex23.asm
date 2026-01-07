; file: broken_sum.asm
global broken_sum
section .text
; uint64_t broken_sum(uint64_t a, uint64_t b)
broken_sum:
    ; BUG: RBX is callee-saved in SysV ABI, but we overwrite it and do not restore it
    mov rbx, rdi
    add rbx, rsi
    mov rax, rbx
    ret
