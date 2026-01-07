; RISC-V: compute boolean without flags via SLT/SLTU.
; slt rd, rs1, rs2 sets rd=1 if rs1<rs2 (signed), else 0.

    .section .text
    .globl _start
_start:
    li      t0, -5
    li      t1, 3
    slt     t2, t0, t1      # t2 = (t0 < t1) ? 1 : 0

    li      a7, 93
    mv      a0, t2
    ecall
