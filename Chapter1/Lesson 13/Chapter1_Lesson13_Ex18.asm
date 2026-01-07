; src/add_u64.asm (NASM)
global add_u64

section .text
; uint64_t add_u64(uint64_t a, uint64_t b)
; SysV AMD64: a in RDI, b in RSI, return in RAX
add_u64:
    lea rax, [rdi + rsi]
    ret
