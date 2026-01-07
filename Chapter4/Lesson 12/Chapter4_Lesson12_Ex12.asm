; Chapter 4 - Lesson 12 (Ex12) — Programming Exercise Solution 3
; Very hard (defensive correctness): checked unsigned division of a 128-bit numerator by a 64-bit denominator.
; Focus: implicit operands of DIV and overflow/zero checks.
;
; Function: div_u128_u64_checked
; Inputs:
;   RDX:RAX = 128-bit numerator (hi:lo)
;   RCX     = denominator (64-bit)
; Outputs:
;   If OK:   CF=0, RAX=quotient (64-bit), RDX=remainder (64-bit)
;   If ERR:  CF=1, RAX/RDX undefined (but we zero them here for cleanliness)
;
; Rationale: DIV raises #DE on denom=0 or if quotient doesn't fit in 64 bits.
; We pre-check:
;   - denom == 0  -> error
;   - hi >= denom -> quotient >= 2^64 -> error

bits 64
default rel
global _start

section .text
div_u128_u64_checked:
    test    rcx, rcx
    jz      .err

    cmp     rdx, rcx
    jae     .err                ; overflow risk

    div     rcx                 ; implicit: uses RDX:RAX, writes RAX/RDX
    clc
    ret

.err:
    xor     eax, eax
    xor     edx, edx
    stc
    ret

_start:
    ; Test case 1: ok: (hi=0, lo=1000) / 7
    mov     rax, 1000
    xor     edx, edx
    mov     rcx, 7
    call    div_u128_u64_checked
    jc      .fail
    ; quotient should be 142, remainder 6
    cmp     rax, 142
    jne     .fail
    cmp     rdx, 6
    jne     .fail

    ; Test case 2: overflow: hi >= denom
    mov     rax, 0
    mov     rdx, 7
    mov     rcx, 7
    call    div_u128_u64_checked
    jnc     .fail               ; must error

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall
