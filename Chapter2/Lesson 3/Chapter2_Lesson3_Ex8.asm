; Compute rax = rbx + 4*rcx + 8 without memory access and without flag changes.
lea rax, [rbx + rcx*4 + 8]

; Contrast: ADD would change flags, and MOV would access memory if given a memory operand.
