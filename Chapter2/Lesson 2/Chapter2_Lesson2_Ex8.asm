; Load a[i] where:
;   rdi = &a[0]
;   ecx = i
;   element size = 4 bytes
; Result in eax

movsxd rcx, ecx              ; sign-extend i to 64-bit if i is signed
mov eax, dword [rdi + rcx*4]  ; eax = a[i]
