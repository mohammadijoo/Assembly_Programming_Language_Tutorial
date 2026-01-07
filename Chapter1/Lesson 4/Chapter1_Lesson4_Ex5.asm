; AArch64 (conceptual, GNU/LLVM-like syntax)
; x0 = x1 + x2
add x0, x1, x2

; Load/store: x3 = *(uint64_t*)(x4 + 16)
ldr x3, [x4, #16]

; *(uint64_t*)(x4 + 16) = x3
str x3, [x4, #16]
