BITS 64
default rel
global _start

; Ex3: 128-bit addition using ADD/ADC on two 64-bit limbs.
; Carry-out is stored in carry_out (byte).

section .data
    ; Little-endian limbs: low qword first
    A dq 0xFFFFFFFFFFFFFFFF, 0x0000000000000001
    B dq 0x0000000000000002, 0x0000000000000003

    SUM dq 0, 0
    carry_out db 0

section .text
_start:
    clc                         ; carry-in = 0
    mov rax, [A + 0]
    adc rax, [B + 0]            ; using ADC works because CF=0
    mov [SUM + 0], rax

    mov rax, [A + 8]
    adc rax, [B + 8]            ; includes carry from low limb
    mov [SUM + 8], rax

    setc byte [carry_out]       ; final carry (0/1)

    mov eax, 60
    xor edi, edi
    syscall
