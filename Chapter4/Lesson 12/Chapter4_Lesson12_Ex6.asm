; Chapter 4 - Lesson 12 (Ex6)
; Partial registers: writing AL/AH/AX does NOT clear upper bits of EAX/RAX.
; Pitfall: using a "narrow" write and later treating the full register as clean.
; Fix patterns: MOVZX/MOVSX or an explicit AND, or writing EAX to zero-extend into RAX.

bits 64
default rel
global _start

section .text
_start:
    ; Suppose RAX holds unrelated high bits
    mov     rax, 0x1122334455667700

    ; You want AL = 1 (true/false) and later compare RAX against 1
    mov     al, 1               ; ONLY low 8 bits change; upper bits remain 0x...7700

    ; RAX is NOT equal to 1; it's 0x1122334455667701 now.
    cmp     rax, 1
    ; ZF=0 here: bug if you expected equality.

    ; Correct: zero-extend AL into EAX (or RAX) when you need a clean boolean value
    movzx   eax, al             ; EAX=1 and, in 64-bit mode, writing EAX zero-extends to RAX

    cmp     rax, 1              ; now ZF=1

    mov     eax, 60
    xor     edi, edi
    syscall
