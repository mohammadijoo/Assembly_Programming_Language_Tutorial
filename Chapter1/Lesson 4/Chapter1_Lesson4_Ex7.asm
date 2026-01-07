; RISC-V RV64I (conceptual)
; x10 (a0) = x11 (a1) + x12 (a2)
add x10, x11, x12

; x5 (t0) = *(uint64_t*)(x6 (t1) + 16)
ld x5, 16(x6)

; *(uint64_t*)(x6 + 16) = x5
sd x5, 16(x6)
