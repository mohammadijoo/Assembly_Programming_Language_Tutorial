# cfi_demo_gas.s (illustrative; not a complete ABI lesson)
    .text
    .globl cfi_demo
cfi_demo:
    .cfi_startproc
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset %rbp, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register %rbp

    # ... body ...
    xor %eax, %eax

    pop %rbp
    .cfi_def_cfa %rsp, 8
    ret
    .cfi_endproc