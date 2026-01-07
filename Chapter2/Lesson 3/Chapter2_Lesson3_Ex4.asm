; Load a 64-bit value from memory:
;   rax = [rbx + rcx*4 + 16]
; This uses base=rbx, index=rcx, scale=4, disp=16.

lea rdx, [rbx + rcx*4 + 16]  ; computes address only
mov rax, [rdx]               ; loads memory

; Or directly:
mov rax, [rbx + rcx*4 + 16]
