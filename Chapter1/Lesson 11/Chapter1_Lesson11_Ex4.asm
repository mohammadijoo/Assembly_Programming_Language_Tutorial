; x86-64 (SysV), compute &arr[i] where arr is int32_t* and i is int64_t
; Inputs:
;   RDI = arr (int32_t*)
;   RSI = i   (int64_t)
; Output:
;   RAX = &arr[i]

lea rax, [rdi + rsi*4]   ; scale by sizeof(int32_t)=4
