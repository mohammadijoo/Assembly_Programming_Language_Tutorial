# u64_sum_gas_att.s (SysV AMD64)
# a=%rdi, n=%rsi
    .text
    .globl u64_sum
u64_sum:
    xor %rax, %rax
    test %rsi, %rsi
    jz .done

.loop:
    add (%rdi), %rax
    add $8, %rdi
    dec %rsi
    jnz .loop

.done:
    ret