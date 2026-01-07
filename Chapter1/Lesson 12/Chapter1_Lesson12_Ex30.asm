; encoding_target.s
    .text
    .globl enc_target
enc_target:
    mov r8,  rax
    mov rax, r8
    add rax, r9
    ret