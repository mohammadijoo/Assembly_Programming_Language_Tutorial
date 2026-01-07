; RISC-V RV64 example: comparisons are explicit (branches compare registers).
; Here we compute (a < b) signed using blt and return 1/0.

    .section .text
    .globl _start
_start:
    li      t0, -5         # a
    li      t1, 3          # b
    li      t2, 0          # result

    blt     t0, t1, is_less
    j       done
is_less:
    li      t2, 1
done:
    li      a7, 93
    mv      a0, t2
    ecall
