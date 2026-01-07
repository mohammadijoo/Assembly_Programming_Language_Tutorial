; AArch64: branchless max(x0, x1) into x2
cmp x0, x1
csel x2, x0, x1, ge   ; if x0 >= x1 then x2=x0 else x2=x1
