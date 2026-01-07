BITS 64
default rel
global _start

; Ex5: N-limb (qword) multi-precision addition: OUT = A + B (mod 2^(64*N)).
; We keep the carry in CF across iterations by using ADC.
; At the end, carry_out holds the carry beyond the top limb.

%define N 6

section .data
    A dq 0xFFFFFFFFFFFFFFFF, 0x0, 0x123456789ABCDEF0, 0x1, 0x0, 0x7
    B dq 0x1,               0x0, 0x0,               0x2, 0xFFFFFFFFFFFFFFFF, 0x9
    OUT times N dq 0
    carry_out db 0

section .text
_start:
    clc                         ; carry-in = 0
    xor rcx, rcx                ; i = 0

.add_loop:
    mov rax, [A + rcx*8]
    adc rax, [B + rcx*8]
    mov [OUT + rcx*8], rax
    inc rcx
    cmp rcx, N
    jne .add_loop

    setc byte [carry_out]

    mov eax, 60
    xor edi, edi
    syscall
