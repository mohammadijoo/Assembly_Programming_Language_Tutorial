; goodcallee.asm
default rel
global badcallee

section .text
badcallee:
    push rbx
    mov rbx, 0x1122334455667788
    pop rbx
    ret
