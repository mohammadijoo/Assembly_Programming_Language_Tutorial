; Example: x86-64 register widths (conceptual)
; rax: 64-bit, eax: 32-bit, ax: 16-bit, al: 8-bit

mov     rax, 0x1122334455667788
mov     eax, 0xAABBCCDD        ; writes low 32 bits (upper behavior is architecture-defined; on x86-64 it zero-extends)
mov     ax,  0x1357
mov     al,  0x42

; Use temporary registers to stage operations
mov     rbx, rax
xor     rcx, rcx              ; set rcx = 0 efficiently
inc     rcx
