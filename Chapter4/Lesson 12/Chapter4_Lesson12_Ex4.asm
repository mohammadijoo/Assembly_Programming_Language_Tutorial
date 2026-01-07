; Chapter 4 - Lesson 12 (Ex4)
; Implicit operands: variable shifts/rotates use CL as the shift count.
; Pitfall: forgetting that SHL r64, r64 is illegal; only CL or imm8 are allowed.

bits 64
default rel
global _start

section .text
_start:
    mov     rax, 1

    ; BAD (won't assemble): shl rax, rbx
    ; The count must be imm8 or CL (lower 8 bits of RCX).
    ; shl rax, rbx

    ; Correct: put count in CL
    mov     ecx, 13             ; only CL is read
    shl     rax, cl             ; rax = 1 << 13

    ; Another pitfall: ECX is often used as loop counter; cl gets overwritten.
    ; Defensive pattern: reload CL close to use site.

    mov     eax, 60
    xor     edi, edi
    syscall
