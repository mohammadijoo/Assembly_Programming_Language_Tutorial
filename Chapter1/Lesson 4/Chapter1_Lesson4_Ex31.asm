; Non-atomic increment (single-threaded correctness only)
ldr x1, [x0]     ; x0 = ptr
add x1, x1, #1
str x1, [x0]
