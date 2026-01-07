; mov rax, imm64 can be encoded with an opcode that implies the destination register.
; In x86-64: REX.W + B8+r + imm64

mov rax, 0x1122334455667788
