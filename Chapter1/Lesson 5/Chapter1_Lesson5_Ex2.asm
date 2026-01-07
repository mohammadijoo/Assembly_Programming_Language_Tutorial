; Assume:
; rdi = pointer to array base (int32_t*)
; rsi = index i
; eax = value to store

; Load array[i] into edx (int32)
mov     edx, dword [rdi + rsi*4]

; Store eax into array[i]
mov     dword [rdi + rsi*4], eax

; Compute address of array[i] (pointer arithmetic) without touching memory
lea     rcx, [rdi + rsi*4]     ; rcx = &array[i]

; Structure-like access: field at offset 16 bytes from base pointer rbx
mov     r8,  qword [rbx + 16]  ; r8 = *(uint64_t*)(rbx + 16)
