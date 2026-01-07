# macros_gas.s (GAS macro facilities)
    .macro DEF_FUNC name
        .globl \name
\name:
    .endm

    .macro PUSH_REG reg
        push \reg
    .endm

    .macro POP_REG reg
        pop \reg
    .endm

    .section .text
    DEF_FUNC add_u64_gas
        # SysV AMD64: a=%rdi, b=%rsi
        mov %rdi, %rax
        add %rsi, %rax
        ret

    # Example: generate a small jump table-like block with .rept
    .globl pattern_block
pattern_block:
    .rept 4
        nop
    .endr
    ret