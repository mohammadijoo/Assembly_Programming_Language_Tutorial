; RISC-V: base in x10, i in x11
; x12 = x10 + (x11 << 3)
slli x12, x11, 3
add  x12, x12, x10
