; Inputs: a_lo=rax, a_hi=rdx, b_lo=rbx, b_hi=rcx
; Outputs: s_lo=rax, s_hi=rdx

add rax, rbx      ; low 64-bit
adc rdx, rcx      ; high 64-bit + carry
