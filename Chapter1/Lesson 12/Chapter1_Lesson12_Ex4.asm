; use_macros_nasm.asm
; Assemble: nasm -f elf64 use_macros_nasm.asm -o use_macros_nasm.o

%include "macros_nasm.inc"

section .text
DEF_FUNC add_u64
    ; uint64_t add_u64(uint64_t a, uint64_t b) in SysV:
    ; a in rdi, b in rsi, return in rax
    mov rax, rdi
    add rax, rsi
    ret