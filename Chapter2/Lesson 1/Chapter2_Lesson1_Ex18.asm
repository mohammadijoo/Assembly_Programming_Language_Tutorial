; Example: making invariants explicit via comments
; Pre: RDI points to array base, RSI = index (unsigned), RDX = length
; Goal: if (index < length) load element into RAX else return 0

cmp rsi, rdx               ; unsigned compare index vs length
jae .oob                   ; if index >= length: out-of-bounds
mov rax, [rdi + rsi*8]     ; load qword element
ret
.oob:
xor eax, eax               ; return 0
ret
