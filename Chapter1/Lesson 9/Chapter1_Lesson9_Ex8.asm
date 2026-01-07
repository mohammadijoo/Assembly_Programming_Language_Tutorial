; callee.asm
default rel
global callee

section .text
callee:
    mov eax, 999
    ret
