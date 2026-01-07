; src/strlen_asm.asm (NASM)
global strlen_asm

section .text
; size_t strlen_asm(const char* s)
; SysV AMD64: s in RDI, return in RAX
strlen_asm:
    xor eax, eax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret
