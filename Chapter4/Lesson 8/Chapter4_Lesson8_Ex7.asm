BITS 64
default rel
global _start

; Ex7: Increment a multi-precision integer in place: X = X + 1 (mod 2^(64*N)).
; Uses early-exit: once CF clears, remaining limbs are unchanged.

%define N 6

section .data
    X dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0x0, 0x7, 0x8, 0x9
    overflow_out db 0

section .text
_start:
    ; Add 1 to the lowest limb
    add qword [X + 0], 1
    jnc .done                   ; no carry -> finished

    ; Propagate carry with ADC 0
    mov rcx, 1
.propagate:
    adc qword [X + rcx*8], 0    ; X[i] = X[i] + CF
    jnc .done
    inc rcx
    cmp rcx, N
    jne .propagate

    ; If we fell through, we overflowed beyond top limb
    ; (CF still set here)
.done:
    setc byte [overflow_out]

    mov eax, 60
    xor edi, edi
    syscall
