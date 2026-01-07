BITS 64
default rel

; Ex10: NASM macro "header-style" patterns for multi-precision add/sub.
; In a real project you would move these macros to a file like mp_arith.inc and %include it.
; Here we keep it in one file for copy/paste convenience.

%macro MP_ADD_QWORDS 5
    ; MP_ADD_QWORDS out, a, b, n, tmpreg
    ; out/a/b are pointers (registers). n is a register/imm. tmpreg is a GPR.
    ; Computes out[i] = a[i] + b[i] for i=0..n-1, returns carry in CF.
    clc
    xor rcx, rcx
%%loop:
    mov %5, [%2 + rcx*8]
    adc %5, [%3 + rcx*8]
    mov [%1 + rcx*8], %5
    inc rcx
    cmp rcx, %4
    jne %%loop
%endmacro

%macro MP_SUB_QWORDS 5
    ; MP_SUB_QWORDS out, a, b, n, tmpreg
    ; Computes out[i] = a[i] - b[i], returns borrow in CF (CF=1 means borrow).
    clc
    xor rcx, rcx
%%loop:
    mov %5, [%2 + rcx*8]
    sbb %5, [%3 + rcx*8]
    mov [%1 + rcx*8], %5
    inc rcx
    cmp rcx, %4
    jne %%loop
%endmacro

global _start
section .data
    A dq 1,2,3,4
    B dq 5,6,7,8
    OUT times 4 dq 0
    carry_out db 0

section .text
_start:
    lea rdi, [OUT]
    lea rsi, [A]
    lea rdx, [B]
    mov r8, 4

    ; Use the macro (tmpreg = rax)
    MP_ADD_QWORDS rdi, rsi, rdx, r8, rax
    setc byte [carry_out]

    mov eax, 60
    xor edi, edi
    syscall
