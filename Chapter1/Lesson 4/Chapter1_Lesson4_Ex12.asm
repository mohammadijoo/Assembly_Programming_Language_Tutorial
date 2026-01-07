; RISC-V RV64: x10 = ptr, x11 = val
ld x5, 0(x10)
add x5, x5, x11
sd x5, 0(x10)
