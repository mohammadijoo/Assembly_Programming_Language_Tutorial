; rax = rdi + rsi*4 + 16  (no memory access)
lea rax, [rdi + rsi*4 + 16]

; rbx = 5*rcx  (rcx + rcx*4), useful for index math
lea rbx, [rcx + rcx*4]
