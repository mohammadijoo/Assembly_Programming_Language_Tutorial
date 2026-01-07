; file: b.asm
default rel

global ext_func

section .text
ext_func:
    ; Do something visible for debugging:
    ; return (7*6) in EAX
    mov eax, 7
    imul eax, 6
    ret
