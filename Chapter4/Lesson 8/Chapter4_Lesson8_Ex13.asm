BITS 64
default rel

; Ex13 (Exercise Solution 3): Multi-precision negation via "0 - X" using SBB chain.
; void mp_neg_qwords(uint64_t* out, const uint64_t* x, size_t n);
;
; Key idea:
;   out[i] = 0 - x[i] - borrow_in
; which is exactly: SBB reg, [x+i] with reg initialized to 0.
;
; Includes a harness.

global mp_neg_qwords
global _start

%define N 4

section .data
    X dq 1, 0, 0, 0
    OUT times N dq 0

section .text
mp_neg_qwords:
    ; rdi=out, rsi=x, rdx=n
    test rdx, rdx
    jz .done

    clc                         ; borrow-in = 0
    xor rcx, rcx
.loop:
    xor r8, r8                  ; r8 = 0 each iteration
    sbb r8, [rsi + rcx*8]       ; r8 = 0 - x[i] - CF
    mov [rdi + rcx*8], r8
    inc rcx
    cmp rcx, rdx
    jne .loop

.done:
    ret

_start:
    lea rdi, [OUT]
    lea rsi, [X]
    mov rdx, N
    call mp_neg_qwords

    mov eax, 60
    xor edi, edi
    syscall
