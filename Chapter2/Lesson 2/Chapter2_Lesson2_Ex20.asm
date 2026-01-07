; RDI = base
; ESI = i
; EDX = j
; ECX = C

; Sign-extend i and j to 64-bit
movsxd rsi, esi
movsxd rdx, edx

; Compute i*C using a shift/add decomposition.
; Since C is runtime value, we cannot replace multiply with fixed shifts in general.
; However, we can implement a shift-add multiply (binary method) without IMUL.

; We'll compute r8 = i*C using "Russian peasant multiplication":
; r8 = 0
; r9 = i
; r10 = C
xor r8, r8
mov r9, rsi
mov r10d, ecx
movzx r10, r10w          ; keep it small-ish; still correct for C up to 65535 (adjust as needed)

.mul_loop:
test r10, r10
jz .mul_done

; If (r10 & 1) r8 += r9
test r10, 1
jz .skip_add
add r8, r9
.skip_add:

; r9 <<= 1; r10 >>= 1
shl r9, 1
shr r10, 1
jmp .mul_loop

.mul_done:
; r8 = i*C
add r8, rdx              ; r8 = i*C + j
; byte offset = (i*C + j)*4
mov eax, dword [rdi + r8*4]
