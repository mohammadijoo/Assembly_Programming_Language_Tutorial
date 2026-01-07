; Input: x0 = x
; Output: x0 = abs(x) with wrap for INT64_MIN (stays INT64_MIN)
; mask = x0 >> 63
asr x1, x0, #63
eor x0, x0, x1
sub x0, x0, x1
