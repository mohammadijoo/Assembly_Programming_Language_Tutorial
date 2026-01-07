BITS 64
default rel
global _start

; Ex6: N-limb (qword) multi-precision subtraction: OUT = A - B (mod 2^(64*N)).
; Borrow is carried in CF across iterations by using SBB.
; At the end, borrow_out holds 1 if A < B (unsigned compare), else 0.

%define N 6

section .data
    A dq 0x0, 0x0, 0x0, 0x0, 0x0, 0x1
    B dq 0x1, 0x0, 0x0, 0x0, 0x0, 0x0
    OUT times N dq 0
    borrow_out db 0

section .text
_start:
    clc                         ; borrow-in = 0
    xor rcx, rcx

.sub_loop:
    mov rax, [A + rcx*8]
    sbb rax, [B + rcx*8]
    mov [OUT + rcx*8], rax
    inc rcx
    cmp rcx, N
    jne .sub_loop

    setc byte [borrow_out]

    mov eax, 60
    xor edi, edi
    syscall
