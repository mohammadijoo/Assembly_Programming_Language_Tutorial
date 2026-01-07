; Inputs: rax = x, rbx = lo, rcx = hi
; Output: rax = clamp(x, lo, hi)
; Strategy: rax = max(rax, rbx) then rax = min(rax, rcx)

cmp rax, rbx
cmovl rax, rbx      ; if x < lo, set to lo

cmp rax, rcx
cmovg rax, rcx      ; if x > hi, set to hi
