; RISC-V RV64 example: load/store model basics.
; Not NASM syntax. Arithmetic works on registers; memory is accessed only by loads/stores.

    .section .data
x:
    .word  41

    .section .text
    .globl _start
_start:
    la      t0, x          # address of x
    lw      t1, 0(t0)      # t1 = x
    addi    t1, t1, 1      # t1 = t1 + 1
    sw      t1, 0(t0)      # x = t1

    # exit with low byte of t1 (Linux RISC-V: a7=93, a0=status)
    li      a7, 93
    mv      a0, t1
    ecall
