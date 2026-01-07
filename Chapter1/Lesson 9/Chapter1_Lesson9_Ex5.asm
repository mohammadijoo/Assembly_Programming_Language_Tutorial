; file: compute.asm
default rel
global compute_value

section .text
compute_value:
    ; Compute something non-trivial but deterministic:
    ; value = ((17 * 23) + 99) XOR 0x55
    mov eax, 17
    imul eax, 23
    add eax, 99
    xor eax, 0x55
    ret
