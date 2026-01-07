; Inputs: x10=base, x11=i
; Output: x12 = base + (i << 3)
slli x12, x11, 3
add  x12, x12, x10
