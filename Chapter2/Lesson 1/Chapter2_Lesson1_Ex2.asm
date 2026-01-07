; Prefer this (clean dependency behavior)
xor eax, eax               ; zero RAX cheaply via 32-bit write rule

; Overuse of AH can be problematic in hot code; shown here for awareness
mov ax, 0x1234
mov ah, 0x56               ; modifies bits 8..15 of AX; avoid in optimized code
