; Input: x10 = x
; Output: x10 = abs(x) with wrap for INT64_MIN
; mask = x >> 63 (arithmetic shift right)
srai x5, x10, 63
xor  x10, x10, x5
sub  x10, x10, x5
