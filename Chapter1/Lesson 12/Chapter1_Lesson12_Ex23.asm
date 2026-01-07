; u64_sum_nasm.asm (SysV AMD64)
; a in rdi, n in rsi, return in rax
global u64_sum

section .text
u64_sum:
    xor rax, rax          ; sum = 0
    test rsi, rsi
    jz .done

.loop:
    add rax, [rdi]
    add rdi, 8
    dec rsi
    jnz .loop

.done:
    ret