# u64_sum_gas_intel.s
    .intel_syntax noprefix
    .text
    .globl u64_sum
u64_sum:
    xor rax, rax
    test rsi, rsi
    jz done

loop_start:
    add rax, qword ptr [rdi]
    add rdi, 8
    dec rsi
    jnz loop_start

done:
    ret
    .att_syntax prefix