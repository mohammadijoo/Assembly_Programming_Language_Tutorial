; Input:
;   RAX = base
;   RCX = limit
;   RDX = offset
; Output:
;   If offset <= limit: RAX = base + offset, ZF=1
;   Else:              RAX = 0, ZF=0
; Clobbers:
;   R8

; Check offset <= limit (unsigned)
cmp rdx, rcx
ja  .fail

; Valid: compute base+offset
lea rax, [rax + rdx]
; Set ZF=1 explicitly by comparing zero with zero using a non-destructive trick:
xor r8, r8
cmp r8, r8
ret

.fail:
xor rax, rax
; Set ZF=0 explicitly: compare 0 with 1
xor r8, r8
cmp r8, 1
ret
