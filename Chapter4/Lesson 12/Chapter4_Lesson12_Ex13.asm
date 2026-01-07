; Chapter 4 - Lesson 12 (Ex13) — Programming Exercise Solution 4
; Hard: branchless clamp of signed 64-bit using CMOV without flag clobbering.
; clamp(x, lo, hi):
;   if x < lo: x=lo
;   if x > hi: x=hi
;
; Pitfalls addressed:
;   - CMOV reads flags: you must keep CMP adjacent (no flag-clobber between CMP and CMOV).
;   - Partial-reg booleans: avoid writing AL and then using RAX as boolean later.
;
; Function: clamp_i64
; Inputs:  RDI=x, RSI=lo, RDX=hi
; Output:  RAX=clamped value
; Clobbers: none besides RAX (and flags)

bits 64
default rel
global _start

section .text
clamp_i64:
    mov     rax, rdi            ; candidate = x

    ; if candidate < lo => candidate = lo
    cmp     rax, rsi
    cmovl   rax, rsi            ; signed compare

    ; if candidate > hi => candidate = hi
    cmp     rax, rdx
    cmovg   rax, rdx

    ret

_start:
    ; Tests
    ; Case 1: x below lo
    mov     rdi, -10
    mov     rsi, 0
    mov     rdx, 100
    call    clamp_i64
    cmp     rax, 0
    jne     .fail

    ; Case 2: x in range
    mov     rdi, 77
    mov     rsi, 0
    mov     rdx, 100
    call    clamp_i64
    cmp     rax, 77
    jne     .fail

    ; Case 3: x above hi
    mov     rdi, 101
    mov     rsi, 0
    mov     rdx, 100
    call    clamp_i64
    cmp     rax, 100
    jne     .fail

.ok:
    mov     eax, 60
    xor     edi, edi
    syscall

.fail:
    mov     eax, 60
    mov     edi, 1
    syscall
