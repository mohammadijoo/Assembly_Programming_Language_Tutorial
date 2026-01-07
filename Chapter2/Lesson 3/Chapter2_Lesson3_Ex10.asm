; MUL uses implicit operands:
;   mul r/m64   => RDX:RAX = RAX * r/m64
; If you expected it to use a different register, your code will be wrong.

mov rax, 7
mov rbx, 6
mul rbx           ; RDX:RAX = 42, modifies RDX and flags in ISA-defined ways
