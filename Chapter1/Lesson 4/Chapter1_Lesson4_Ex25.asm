; Inputs: x0 = x, x1 = lo, x2 = hi
; Output: x0 = clamp(x, lo, hi)

cmp  x0, x1
csel x0, x1, x0, lt   ; x0 = (x0 < lo) ? lo : x0

cmp  x0, x2
csel x0, x2, x0, gt   ; x0 = (x0 > hi) ? hi : x0
