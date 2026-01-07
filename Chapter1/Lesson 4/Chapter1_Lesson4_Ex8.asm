; RISC-V: compute max(x10, x11) into x12 (branchless version)
; t0 = (x10 < x11) ? 1 : 0  (signed compare)
slt x5, x10, x11

; If t0==0 then x12=x10 else x12=x11
; x12 = x10 + t0*(x11 - x10)
sub x6, x11, x10
mul x6, x6, x5     ; requires M extension (mul)
add x12, x10, x6
