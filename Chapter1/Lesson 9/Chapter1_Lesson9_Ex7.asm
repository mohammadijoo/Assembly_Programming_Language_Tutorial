; caller.asm
default rel
global caller
extern callee

section .text
caller:
    call callee
    mov eax, 1
    ret
