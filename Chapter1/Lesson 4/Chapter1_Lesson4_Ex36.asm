; Inputs: rdi = base, rsi = i
; Output: rax = base + i*8
lea rax, [rdi + rsi*8]
