BITS 64
default rel
global _start

; Ex4: 128-bit subtraction using SUB/SBB on two 64-bit limbs.
; Borrow-out is stored in borrow_out (byte). CF=1 means borrow occurred.

section .data
    A dq 0x0000000000000000, 0x0000000000000002
    B dq 0x0000000000000001, 0x0000000000000000

    DIFF dq 0, 0
    borrow_out db 0

section .text
_start:
    clc                         ; borrow-in = 0
    mov rax, [A + 0]
    sbb rax, [B + 0]            ; sbb with CF=0 behaves like sub
    mov [DIFF + 0], rax

    mov rax, [A + 8]
    sbb rax, [B + 8]            ; subtract next limb with propagated borrow
    mov [DIFF + 8], rax

    setc byte [borrow_out]

    mov eax, 60
    xor edi, edi
    syscall
