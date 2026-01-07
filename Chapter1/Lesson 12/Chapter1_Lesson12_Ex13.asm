; aarch64_demo.s (illustrative, not x86; shown to emphasize multi-target usage)
; add x0, x0, x1
; ret

    .text
    .globl add_u64_aarch64
add_u64_aarch64:
    add x0, x0, x1
    ret