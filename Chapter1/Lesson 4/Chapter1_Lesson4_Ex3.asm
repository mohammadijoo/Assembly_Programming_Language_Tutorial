; x86-64 example: 64-bit add, Intel syntax (conceptual)
; rax = rax + rbx
add rax, rbx

; 32-bit write zero-extends to 64-bit (important semantic detail)
; eax write sets upper 32 bits of rax to zero
mov eax, 1        ; rax becomes 0x0000000000000001
