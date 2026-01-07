; Chapter 4 - Lesson 12 (Ex8)
; Flag clobbering: many "harmless" instructions overwrite flags (ADD/SUB/AND/OR/XOR/TEST/INC/DEC, etc.).
; Pitfall: doing CMP, then inserting an instruction that changes flags, then Jcc/CMOV/SETcc based on CMP.
; Fix: (1) keep flag-dependent ops adjacent, (2) prefer LEA for arithmetic that must preserve flags,
;      (3) save/restore flags (PUSHFQ/POPFQ) if truly needed (expensive).

bits 64
default rel
global _start

section .text
_start:
    mov     rax, 5
    mov     rbx, 9

    ; You want to branch based on (rax < rbx) (signed or unsigned, pick carefully)
    cmp     rax, rbx            ; sets flags for compare

    ; BUG: this clobbers flags, so the next Jcc no longer uses CMP's result
    add     rcx, 1              ; RCX is uninitialized here; included only to demonstrate flag clobbering

    ; The following condition is now meaningless w.r.t. CMP above
    jl      .less               ; signed less-than, but flags are from ADD

    ; Correct pattern 1: keep Jcc adjacent (no intervening flag-setting ops)
    ; Correct pattern 2: if you must compute something, use LEA (does not change flags)
    cmp     rax, rbx
    lea     rcx, [rcx + 1]      ; arithmetic without flag clobber
    jl      .less

.not_less:
    mov     eax, 60
    xor     edi, edi
    syscall

.less:
    mov     eax, 60
    xor     edi, edi
    syscall
