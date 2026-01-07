; Inputs: x10=a0=x, x11=a1=lo, x12=a2=hi
; Output: x10=a0=clamp(x, lo, hi)
; Uses: x5=t0, x6=t1
;
; Step1: if x < lo: x = lo
slt  x5, x10, x11        ; t0 = (x < lo)
sub  x6, x11, x10        ; t1 = (lo - x)
and  x6, x6, x5          ; if t0==1 keep delta else zero (requires t0 be 0/1)
add  x10, x10, x6        ; x += (lo-x) if needed

; Step2: if hi < x: x = hi   (i.e., x > hi)
slt  x5, x12, x10        ; t0 = (hi < x)  equivalent to (x > hi)
sub  x6, x12, x10        ; t1 = (hi - x)
and  x6, x6, x5
add  x10, x10, x6
