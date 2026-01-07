; Input: rax = x
; Output: rax = abs(x) with wrap for x = INT64_MIN (stays INT64_MIN)
; mask = x >> 63 (all 1s if negative else 0)
mov rdx, rax
sar rdx, 63
xor rax, rdx
sub rax, rdx
