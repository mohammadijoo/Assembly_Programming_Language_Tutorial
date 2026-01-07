; Chapter 4 - Lesson 12 (Ex10) — Programming Exercise Solution 1
; Very hard: 256-bit addition with correct carry handling, emphasizing flag discipline.
; Adds A[4] + B[4] (each 4 qwords, little-endian limbs) -> OUT[4], returns carry-out in BL.
; Demonstrates: ADC chain must be uninterrupted by flag-clobbering instructions.
; Validation: compares output with expected constants and exits with 0 on success, 1 on failure.

bits 64
default rel
global _start

section .data
A:      dq 0xFFFFFFFFFFFFFFFF, 0x0000000000000000, 0x7FFFFFFFFFFFFFFF, 0x0000000000000001
B:      dq 0x0000000000000001, 0xFFFFFFFFFFFFFFFF, 0x0000000000000001, 0xFFFFFFFFFFFFFFFF
OUT:    dq 0, 0, 0, 0

; Expected:
; limb0: 0x0 (carry 1)
; limb1: 0x0 (carry 1)
; limb2: 0x8000000000000001 (carry 0)
; limb3: 0x0000000000000000 (carry 1) because 1 + FFFF.. = 0 with carry
EXP:    dq 0x0000000000000000, 0x0000000000000000, 0x8000000000000001, 0x0000000000000000
EXP_CARRY: db 1

section .text
_start:
    ; rsi = A, rdi = B, rbx = OUT
    lea     rsi, [A]
    lea     rdi, [B]
    lea     rbx, [OUT]

    ; Limb 0: add sets CF
    mov     rax, [rsi + 0]
    add     rax, [rdi + 0]
    mov     [rbx + 0], rax

    ; Limb 1..3: ADC consumes CF and produces new CF.
    mov     rax, [rsi + 8]
    adc     rax, [rdi + 8]
    mov     [rbx + 8], rax

    mov     rax, [rsi + 16]
    adc     rax, [rdi + 16]
    mov     [rbx + 16], rax

    mov     rax, [rsi + 24]
    adc     rax, [rdi + 24]
    mov     [rbx + 24], rax

    ; Immediately materialize carry-out BEFORE any flag-clobber
    setc    bl                  ; BL = CF (0/1)

    ; Validate OUT limbs
    lea     rsi, [OUT]
    lea     rdi, [EXP]

    mov     rcx, 4
.check_loop:
    mov     rax, [rsi]
    cmp     rax, [rdi]
    jne     .fail
    add     rsi, 8
    add     rdi, 8
    dec     rcx
    jnz     .check_loop

    ; Validate carry-out in BL against EXP_CARRY
    movzx   eax, byte [EXP_CARRY]
    cmp     bl, al
    jne     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall
