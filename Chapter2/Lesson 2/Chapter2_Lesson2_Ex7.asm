; Example: compute ptr = base + i*12 + 32
; scale=8 and scale=4 can be combined using two LEAs (12 = 8 + 4).

; Inputs:
;   rdi = base
;   rsi = i
; Output:
;   rax = ptr

lea rax, [rsi*8]          ; rax = i*8
lea rax, [rax + rsi*4]    ; rax = i*12
add rax, rdi              ; rax = base + i*12
add rax, 32               ; rax = base + i*12 + 32
