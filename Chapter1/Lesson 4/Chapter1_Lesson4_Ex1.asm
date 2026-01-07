; x86 (32-bit) style, Intel syntax (conceptual)
; mem32 += eax
add dword [edi], eax

; load + operate (still common when you want explicit control)
mov edx, dword [edi]
add edx, eax
mov dword [edi], edx
