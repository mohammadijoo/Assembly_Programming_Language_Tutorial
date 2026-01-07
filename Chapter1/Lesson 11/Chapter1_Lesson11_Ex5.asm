; x86 (32-bit), compute &arr[i]
; Inputs:
;   EDI = arr (int32_t*)
;   ESI = i   (int32_t)
; Output:
;   EAX = &arr[i]

lea eax, [edi + esi*4]
