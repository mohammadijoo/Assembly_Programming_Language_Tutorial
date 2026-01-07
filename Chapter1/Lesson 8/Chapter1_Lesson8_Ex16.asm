; file: b_fixed.asm (remove global export)
; util is now local to this object
section .text
util:
    mov eax, 1
    ret
