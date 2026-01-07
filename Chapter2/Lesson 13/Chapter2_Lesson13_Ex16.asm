; Cross-ISA note (comment-only): comparing how "if (a==b) x=1 else x=0" is expressed.
; x86-64 (NASM):
;   cmp eax, ebx
;   sete al
; ARM (A32):
;   cmp r0, r1
;   moveq r2, #1
;   movne r2, #0
; RISC-V:
;   beq t0, t1, equal
;   li t2, 0
;   j done
; equal: li t2, 1

; This file is intentionally non-executable; it is a study aid.
