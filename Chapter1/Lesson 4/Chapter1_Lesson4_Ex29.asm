; Inputs: a_lo=x10, a_hi=x11, b_lo=x12, b_hi=x13
; Outputs: s_lo=x10, s_hi=x11
; Carry detection: carry = (s_lo < a_lo) for unsigned add

add  x10, x10, x12     ; s_lo
sltu x5,  x10, x10     ; WRONG (shown to emphasize pitfall: comparing a register to itself)
; Correct carry detection:
; We must compare s_lo with original a_lo, so preserve a_lo first.

; --- Correct version ---
; Assume original a_lo was saved into x6 before the add:
;   mv x6, x10
;   add x10, x10, x12
;   sltu x5, x10, x6

; Then compute high:
add  x11, x11, x13
add  x11, x11, x5
