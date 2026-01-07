; Inputs: a_lo=x0, a_hi=x1, b_lo=x2, b_hi=x3
; Outputs: s_lo=x0, s_hi=x1

adds x0, x0, x2   ; low, sets carry
adc  x1, x1, x3   ; high + carry
