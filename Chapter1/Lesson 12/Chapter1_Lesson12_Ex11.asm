; encode_demo.s (Intel-like style supported by LLVM in many setups)
; The point here is the *workflow*: assemble with llvm-mc and inspect bytes.

    .text
    .globl add_u64_llvm
add_u64_llvm:
    mov rax, rdi
    add rax, rsi
    ret