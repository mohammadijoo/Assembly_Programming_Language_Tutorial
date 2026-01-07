; Non-atomic increment (single-threaded correctness only)
ld  x5, 0(x10)   ; x10 = ptr
addi x5, x5, 1
sd  x5, 0(x10)
