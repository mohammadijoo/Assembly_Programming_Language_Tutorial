; Example: load from [base + index*scale + disp]
; edx = *(int32_t*)(ebx + esi*4 + 16)
mov edx, dword [ebx + esi*4 + 16]

; Stack-relative example (common in 32-bit ABIs)
; edx = *(int32_t*)(ebp - 8)
mov edx, dword [ebp - 8]
