; file: libf.asm
; int f(int x) { return 3*x + 1; }
default rel
global f

section .text
f:
    lea eax, [edi + 2*edi]  ; eax = 3*x (using LEA arithmetic)
    add eax, 1
    ret
