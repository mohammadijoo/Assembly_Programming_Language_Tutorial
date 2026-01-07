; AArch64: x0 = ptr, x1 = val
ldr x2, [x0]
add x2, x2, x1
str x2, [x0]
